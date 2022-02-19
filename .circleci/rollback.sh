#!/bin/bash
set -xe

source ./.circleci/common.sh;
env_vars
k8s_dependencies

# Install dependencies

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates gnupg jq kubectl google-cloud-sdk

# Set current cluster

echo $TOKEN_CLUSTER | base64 --decode --ignore-garbage > /tmp/config

# Rollback to the last RS version
kubectl_run rollout undo deployment $APP -n $APP
kubectl rollout status deployment $APP  -n $APP  || kubectl_run rollout status statefulset $APP  -n $APP