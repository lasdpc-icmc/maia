#!/bin/bash
set -xe

# Getting environment info
source ./.circleci/common.sh;
env_vars

# Install dependencies
install_awscli_kubectl
aws_credentials
pip install locust

for file in `find apps/$APP/loadtest/ -type f |grep "\.py$"`; do
    locust                                      \
        --headless                              \
        --config apps/$APP/loadtest/locust.conf \
        -f $file                                \
        --html $(echo $file| cut -d'/' -f 4 | cut -d'.' -f 1).html
done

tar czf result.tar.gz *.html

# Save results to S3
aws_run s3 cp result.tar.gz \
    s3://lasdpc-locust-results/$APP/$APP-$(date +%Y-%m-%d)-$CIRCLE_PREVIOUS_BUILD_NUM.tar.gz

