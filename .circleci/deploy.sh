#!/bin/bash
set -xe
source ./.circleci/common.sh;

# Load common functions and Install dependencies
k8s_dependencies

# Setup Cluster

echo $TOKEN_CLUSTER | base64 --decode --ignore-garbage > /tmp/config


# Deploy

KUBE_CONFIG=$(cat apps/$APP/kubernetes/values.yaml | sed "s|CIRCLE_TAG_REPLACE|$TAG|g")
echo "$KUBE_CONFIG" | kubectl --kubeconfig=/tmp/config apply -f -
kubectl rollout status deployment/$APP -n $APP
get_pod