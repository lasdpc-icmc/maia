#!/bin/bash
set -xe
source ./.circleci/common.sh;

# Load common functions and Install dependencies
k8s_dependencies
env_vars

# Setup Cluster

echo $TOKEN_CLUSTER | base64 --decode --ignore-garbage > /tmp/config

# Deploy

KUBE_CONFIG=$(cat apps/$APP/kubernetes/values.yaml | sed "s|CIRCLE_TAG_REPLACE|$TAG|g")
echo "$KUBE_CONFIG" | kubectl_run apply -f -
kubectl_run rollout status deployment/$APP -n $APP