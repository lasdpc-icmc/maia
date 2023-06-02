#!/bin/bash
set -xe

# Getting environment info
source ./.circleci/common.sh;
env_vars

# Install dependencies
install_awscli_kubectl
aws_credentials
pip install locust

# runs the locust loadtest in a single file for a specified time (such as 10s or 2m)
run_locust() {
    locust                                      \
        --autostart --autoquit 0                \
        --config apps/$APP/loadtest/locust.conf \
        --exit-code-on-error 0                  \
        -f $1 -t $2
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

#if we are in the deployment workflow
if [ -z $(echo $CIRCLE_TAG | awk -F "(/)" '{print $4}') ]
then
    #run all tests all at once for a minute
    run_locust $all_files "60s"
else
    #if we are in the loadtest only workflow

    #sets the specific file and time from the tag and run a single test
    if [[ $(echo $CIRCLE_TAG | awk -F "(/)" '{print $2}') == "all" ]]
    then
      file=$all_files
    else
      file=apps/$APP/loadtest/$(echo $CIRCLE_TAG | awk -F "(/)" '{print $2}').py
    fi

    runtime=$(echo $CIRCLE_TAG | awk -F "(/)" '{print $3}')
    run_locust $file $runtime
fi

#kill background metrics sending process
kill $(jobs -p)

#set the metrics to zero before we exit to ensure no metrics linger with values
sed -i 's/^\(locust_[^ ]*\) .*/\1 0/g' locust.metrics
push_to_s3

sleep 30
kubectl_run delete job locust-metrics-distributor -n monitoring

