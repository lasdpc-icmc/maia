#!/bin/bash
set -xe

source ./.circleci/common.sh;

# Install dependencies

k8s_dependencies
env_vars

# Set current cluster

echo $TOKEN_CLUSTER | base64 --decode --ignore-garbage > /tmp/config

# Rollback to the last RS version

kubectl_run rollout undo deployment $APP -n $APP
kubectl_run rollout status deployment $APP -n $APP || kubectl_run rollout status statefulset $APP -n $APP