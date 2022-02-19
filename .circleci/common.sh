#!/bin/bash
set -xe

env_vars() {
  echo "export APP=$(echo $CIRCLE_TAG | awk -F "(/)" '{print $1}')" >> $BASH_ENV
  echo "export ENV=$(echo $CIRCLE_TAG | awk -F "(/)" '{print $2}' | awk -F "(-)" '{print $1}')" >> $BASH_ENV
  echo "export TAG=$(echo $CIRCLE_TAG | awk -F "(/)" '{print $2}')" >> $BASH_ENV
  source $BASH_ENV
}

gke_credentials() {
  env_vars
  if [[ "$ENV" == "prod" ]]; then
    echo "export GCLOUD_SERVICE_KEY=$GCLOUD_SERVICE_KEY_PROD" >> $BASH_ENV
    echo "export GOOGLE_CLUSTER_NAME=$GOOGLE_CLUSTER_NAME_PROD" >> $BASH_ENV
    echo "export GOOGLE_PROJECT_ID=$GOOGLE_PROJECT_ID_PROD" >> $BASH_ENV
    echo "export GOOGLE_COMPUTE_ZONE=$GOOGLE_COMPUTE_ZONE_PROD" >> $BASH_ENV
    echo "export GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN_PROD" >> $BASH_ENV
    echo "export SLACK_WEBHOOK=$SLACK_WEBHOOK_PROD" >> $BASH_ENV

  elif [[ "$ENV" == "stg" ]]; then
    echo "export GCLOUD_SERVICE_KEY=$GCLOUD_SERVICE_KEY_STG" >> $BASH_ENV
    echo "export GOOGLE_CLUSTER_NAME=$GOOGLE_CLUSTER_NAME_STG" >> $BASH_ENV
    echo "export GOOGLE_PROJECT_ID=$GOOGLE_PROJECT_ID_STG" >> $BASH_ENV
    echo "export GOOGLE_COMPUTE_ZONE=$GOOGLE_COMPUTE_ZONE_STG" >> $BASH_ENV
    echo "export GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN_STG" >> $BASH_ENV
    echo "export SLACK_WEBHOOK=$SLACK_WEBHOOK_STG" >> $BASH_ENV

  fi
  source $BASH_ENV
}

get_pod() {
  kubectl_run get pods -n $APP -o \
  jsonpath='{range .items[]}{"pod: "}{.metadata.name}{"\n"} \
  {range .spec.containers[*]}{"\tname: "}{.name}{"\n\timage: "}{.image}{"\n"}{end}'
}

kubectl_run() {
  kubectl --kubeconfig=/tmp/config "$@"

  if [ $? -eq 1 ]; then
    echo "kubectl cmd failed"
    exit 1;
  fi
}

install_helm3 () {
sudo wget https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz
sudo tar -zxvf helm-v3.2.4-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
}

helm_run() {
  helm "$@"

  if [ $? -eq 1 ]; then
    echo "HELM cmd failed"
    exit 1;
  fi
}

git_config () {
  git config --global user.email "lsdpc@usp.br"
  git config --global user.name "CircleCI USP"
}

k8s_dependencies () {
sudo echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
sudo curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates gnupg jq kubectl google-cloud-sdk
}