#!/bin/bash
set -xe

env_vars() {
  echo "export APP=$(echo $CIRCLE_TAG | awk -F "(/)" '{print $1}')" >> $BASH_ENV
  echo "export ENV=$(echo $CIRCLE_TAG | awk -F "(/)" '{print $2}' | awk -F "(-)" '{print $1}')" >> $BASH_ENV
  echo "export TAG=$(echo $CIRCLE_TAG | awk -F "(/)" '{print $2}')" >> $BASH_ENV
  source $BASH_ENV
}

aws_run() {
  aws "$@"

  if [ $? -eq 1 ]; then
    echo "AWS cmd failed"
    exit 1;
  fi
}

aws_credentials() {
  env_vars
  if [[ "$ENV" == "prod" ]]; then
    echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID_PROD" >> $BASH_ENV
    echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY_PROD" >> $BASH_ENV
    echo "export EKS_CLUSTER_NAME=$PROD_CLUSTER_NAME" >> $BASH_ENV
    echo "export EKS_REGION=$PROD_EKS_REGION" >> $BASH_ENV
  elif [[ "$ENV" == "stg" ]]; then
    echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID_STG" >> $BASH_ENV
    echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY_STG" >> $BASH_ENV
    echo "export EKS_CLUSTER_NAME=$STG_CLUSTER_NAME" >> $BASH_ENV
    echo "export EKS_REGION=$STG_EKS_REGION" >> $BASH_ENV
  fi
  source $BASH_ENV
}

get_pod() {
  kubectl_run get pods -n $APP -o \
  jsonpath='{range .items[]}{"pod: "}{.metadata.name}{"\n"} \
  {range .spec.containers[*]}{"\tname: "}{.name}{"\n\timage: "}{.image}{"\n"}{end}'
}

kubectl_run() {
  kubectl "$@"

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

install_awscli_kubectl() {
  sudo apt-get update
  sudo apt-get install awscli
  curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
  chmod +x ./aws-iam-authenticator
  sudo mv ./aws-iam-authenticator /usr/local/bin
  curl -o kubectl https://storage.googleapis.com/kubernetes-release/release/v1.15.11/bin/linux/amd64/kubectl
  chmod +x "kubectl" && sudo mv "kubectl" /usr/local/bin/
  curl -L  https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
}