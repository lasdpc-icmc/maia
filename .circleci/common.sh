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

  curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.29.0/2023-03-02/bin/linux/amd64/aws-iam-authenticator
  chmod +x ./aws-iam-authenticator
  sudo mv ./aws-iam-authenticator /usr/local/bin

  curl -o kubectl https://storage.googleapis.com/kubernetes-release/release/v1.29.0/bin/linux/amd64/kubectl
  chmod +x "kubectl" && sudo mv "kubectl" /usr/local/bin/
  curl -L https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

}

vault_set_permissions () {

  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install -y vault
  sudo apt-get install --reinstall -y vault
  # Create the Vault server Setup
  export VAULT_ADDR=$VAULT_ADDRESS
  export VAULT_TOKEN=$VAULT_TOKEN
  vault auth enable kubernetes | sh 2>&1 >/dev/null || true
  vault status
  vault policy write $APP -<< EOF
  path "k8s-secrets/data/$APP"
  {  capabilities = ["read"]
  }
EOF

  k8s_host="$(kubectl exec vault-0 -n vault -- printenv | grep KUBERNETES_PORT_443_TCP_ADDR | cut -f 2- -d "=" | tr -d " ")"
  k8s_port="443"
  k8s_cacert="$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 --decode)"

  secret_name="$(kubectl get secrets -n vault | grep vault-token | grep -v boot | awk {'print $1'})"
  export tr_account_token="$(kubectl get secret ${secret_name} -n vault  -o jsonpath="{.data.token}" | base64 --decode; echo)"

  vault write auth/kubernetes/config token_reviewer_jwt="${tr_account_token}" kubernetes_host="https://${k8s_host}:${k8s_port}" kubernetes_ca_cert="${k8s_cacert}"
  disable_issuer_verification=true

  demo_secret_name="$(kubectl get secrets -n $APP | grep $APP-token | awk {'print $1'})"
  demo_account_token="$(kubectl get secret ${demo_secret_name} -n $APP -o jsonpath="{.data.token}" | base64 --decode; echo)"

  vault write auth/kubernetes/role/role-$APP \
      bound_service_account_names="$APP" \
      bound_service_account_namespaces="$APP" \
      policies="$APP" \
      ttl=24h

  vault write auth/kubernetes/login role="role-$APP" jwt=$demo_account_token iss=https://kubernetes.default.svc.cluster.local

}