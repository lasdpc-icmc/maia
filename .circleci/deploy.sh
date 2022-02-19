#!/bin/bash
set -xe
source ./.circleci/common.sh;

# Load common functions and Install dependencies
k8s_dependencies
env_vars

# Setup Cluster

echo $TOKEN_CLUSTER | base64 --decode --ignore-garbage > /tmp/config

# Deploy

sed -i "s/CIRCLE_TAG_REPLACE/$TAG/g" apps/$APP/kubernetes/values.yaml
kubectl_run apply -f apps/$APP/kubernetes/values.yaml
# kubectl_run rollout status deployment/$APP -n $APP