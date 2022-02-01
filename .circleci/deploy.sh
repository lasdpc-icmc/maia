#!/bin/bash
set -xe
source ./.circleci/common.sh;

# Load common functions and Install dependencies


# Setup Cluster

E

# Deploy

kubectl rollout status deployment/$APP -n $APP
kubectl_run get pods -n $APP