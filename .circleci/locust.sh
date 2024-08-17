#!/bin/bash
set -xe

# Getting environment info
source ./.circleci/common.sh;
env_vars

# Install dependencies
install_awscli_kubectl
aws_credentials
pip install locust

# setup .kube/config
aws_run eks --region $EKS_REGION update-kubeconfig --name $EKS_CLUSTER_NAME
chmod 600 ~/.kube/config

# identify our workflow and set variables accordingly
if [[ $APP == "testandchaos" ]]
then
    APP=$(echo $CIRCLE_TAG |sed 's|testandchaos/\([^/]*\)/.*|\1|')
    CHAOS=$(echo $CIRCLE_TAG |sed 's|testandchaos/[^/]*/\([^/]*\)/.*|\1|')
else
    CHAOS="none"
fi

# runs the locust loadtest for half an hour, only the files listed in the first argument
run_locust() {
    locust                                      \
        --autostart --autoquit 0                \
        --config apps/$APP/loadtest/locust.conf \
        --exit-code-on-error 0                  \
        -f $1 -t "96h"
}

apply_chaos_after_sleep() {
    sleep 15m
    kubectl_run apply -f apps/$APP/errors/$CHAOS.yaml
    sleep 5m
    kubectl_run delete -f apps/$APP/erros/$CHAOS.yaml
}

#collects all metrics from the local running locust_exporter and pushes them to s3
send_metrics() {
    sleep 5
    while true
    do
        curl localhost:9646/metrics -o locust.metrics
        push_to_s3
        sleep 20
    done
}

push_to_s3(){
    aws_run s3 cp locust.metrics \
        s3://lasdpc-locust-results/$APP/locust.metrics
}

# starts the eks distributor job
kubectl_run apply -f apps/locust-metrics-distributor/kubernetes/

#start background metrics sending process
send_metrics &

all_files=$(find apps/$APP/loadtest/ -maxdepth 1 -type f |grep "\.py$" |sed ':a;N;$!ba;s/\n/,/g')

#if we are in a workflow with chaos-mesh errors
if [[ $CHAOS != "none" ]]
then
  #set a new thread to sleep for some time and apply the chaos after that
  apply_chaos_after_sleep &
fi

START_TIME=$(date +%s)

#run all tests
run_locust $all_files

# start a port-forward to get loki logs for the period of the test
# TODO: this is not a good solution, but any other would be time consuming
kubectl_run port-forward -n monitoring loki-0 3100:3100

END_TIME=$(date +%s)

#get logs from loki and store them in s3
curl "localhost:3100/loki/api/v1/query_range?query=\{namespace=\"$APP\"\}&start=$START_TIME&end=$END_TIME&limit=10000" > logs.json
aws_run s3 cp logs.json "s3://lasdpc-locust-results/$APP/logs-$START_TIME.json"

#kill background metrics sending process and the local port-forward
kill $(jobs -p)

#set the metrics to zero before we exit to ensure no metrics linger with values
sed -i 's/^\(locust_[a-zA-Z0-9_]*\({[^}]*}\)\?\) [0-9\.]*/\1 0/g' locust.metrics
push_to_s3

sleep 30
kubectl_run delete job locust-metrics-distributor -n monitoring

