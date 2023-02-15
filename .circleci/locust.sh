#!/bin/bash
set -xe

# Getting environment info
source ./.circleci/common.sh;
env_vars

# Install dependencies
install_awscli_kubectl
aws_credentials
pip install locust

# Run loadTest
locust                                      \
    --headless                              \
    --config apps/$APP/loadtest/locust.conf \
    -f apps/$APP/loadtest/locustfile.py     \
    --html result.html

# Save results to S3
aws_run s3 cp result.html \
    s3://lasdpc-locust-results/$APP/$APP-$(date +%Y-%m-%d)-$CIRCLE_PREVIOUS_BUILD_NUM.html
