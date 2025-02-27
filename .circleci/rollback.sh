#!/bin/bash
set -xe
source ./.circleci/common.sh;

# Install dependencies

env_vars

# Set current cluster

install_awscli_kubectl
aws_credentials
aws_run eks --region $EKS_REGION update-kubeconfig --name $EKS_CLUSTER_NAME
chmod 600 ~/.kube/config

# Rollback to the last RS version

kubectl_run rollout undo deployment $APP -n $APP
kubectl get deploy -o name -n $APP | xargs -n1 -t kubectl rollout status -n $APP