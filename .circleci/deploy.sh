#!/bin/bash
set -xe
source ./.circleci/common.sh;

# Load common functions and Install dependencies
env_vars

# Deploy
install_awscli_kubectl
aws_credentials
aws_run eks --region $EKS_REGION update-kubeconfig --name $EKS_CLUSTER_NAME
chmod 600 ~/.kube/config
sed -i "s/CIRCLE_TAG_REPLACE/$TAG/g" apps/$APP/kubernetes/values.yaml
kubectl_run apply -f apps/$APP/kubernetes/values.yaml
kubectl_run rollout status deployment/$APP -n $APP