#!/bin/bash
set -xe

# Getting environment info
source ./.circleci/common.sh;
env_vars

# Install dependencies
install_awscli_kubectl
aws_credentials
pip install locust


run_locust() {
    locust                                      \
        --autostart --autoquit 15               \
        --config apps/$APP/loadtest/locust.conf \
        -f $1 -t $2                             \
}

loadtest_all_files() {
    for file in `find apps/$APP/loadtest/ -maxdepth 1 -type f |grep "\.py$"`; do
        run_locust $file "60s"
    done
}

send_metrics() {
    while true
    do
        curl localhost:9646/metrics -o locust.metrics
        push_to_s3
        sleep 15
    done
}

push_to_s3(){
    aws_run s3 cp locust.metrics \
        s3://lasdpc-locust-results/$APP/locust.metrics
}

#start background metrics sending process
send_metrics &

if [ -z $(echo $CIRCLE_TAG | awk -F "(/)" '{print $4}') ]
then
    loadtest_all_files
else
    file=apps/$APP/loadtest/$(echo $CIRCLE_TAG | awk -F "(/)" '{print $2}').py
    runtime=$(echo $CIRCLE_TAG | awk -F "(/)" '{print $3}')
    run_locust $file $runtime
fi

#kill background metrics sending process
kill $(jobs -p)

