#!/bin/bash
set -xe
source ./.circleci/common.sh;

# Load common functions and Install dependencies

env_vars
install_awscli_kubectl
aws_credentials

# Update kubeconfig
aws_run eks --region $EKS_REGION update-kubeconfig --name $EKS_CLUSTER_NAME
chmod 600 ~/.kube/config


# Create Vault Secrets Environment

namespaceStatus=$(kubectl_run get ns $APP -o json --ignore-not-found=true | jq .status.phase -r )
if [ $namespaceStatus == "Active" ]
then
    echo "namespace already exists"
else
   kubectl_run create namespace $APP
   kubectl_run create sa $APP -n $APP | sh 2>&1 >/dev/null || true
   vault_set_permissions
fi

if [ $APP == "deep-log" ]; then

    sed -i "s/CIRCLE_TAG_REPLACE/$TAG/g" apps/$APP/kubernetes/applications/values.yaml
    kubectl_run delete job deep-log-training -n $APP | sh 2>&1 >/dev/null || true
    kubectl_run apply -f apps/$APP/kubernetes/applications/
    #check if all deploys were successfull\
    kubectl_run annotate es external-secrets-$APP force-sync=$(date +%s) --overwrite -n $APP | sh 2>&1 >/dev/null || true

    exit 0
fi

#apply deployment yaml
sed -i "s/CIRCLE_TAG_REPLACE/$TAG/g" apps/$APP/kubernetes/values.yaml
kubectl_run apply -f apps/$APP/kubernetes/values.yaml

# Force sync with Vault Secrets
kubectl annotate es external-secrets-$APP force-sync=$(date +%s) --overwrite -n $APP 2>&1 >/dev/null || true

# Check if all deploys were successful
kubectl get deploy -o name -n $APP | xargs -n1 -t kubectl rollout status -n $APP

#check if all deploys were successfull
kubectl get deploy -o name -n $APP | xargs -n1 -t kubectl rollout status -n $APP
