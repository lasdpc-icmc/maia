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


if [ $APP == "locust-metrics-distributor" ]; then
    sed -i "s|LOCUST_DIST_SECRET_KEY_REPLACE|$LOCUST_DIST_SECRET_KEY_REPLACE|g" \
        apps/$APP/kubernetes/values.yaml
    sed -i "s|LOCUST_DIST_KEY_ID_REPLACE|$LOCUST_DIST_KEY_ID_REPLACE|g" \
        apps/$APP/kubernetes/values.yaml
elif [ $APP == "deep-log" ]; then
    sed -i "s/CIRCLE_TAG_REPLACE/$TAG/g" apps/$APP/kubernetes/applications/values.yaml
    kubectl_run delete job deep-log-training deeplog-prom-exporter -n $APP | sh 2>&1 >/dev/null || true
    kubectl_run apply -f apps/$APP/kubernetes/applications/
    #check if all deploys were successfull\
    kubectl_run wait --for=condition=complete job/deep-log-training --timeout=900s -n $APP

    # run the exporter job to send metrics to prometheus
    kubectl_run apply -f apps/deeplog-prom-exporter/kubernetes/
    kubectl_run wait --for=condition=complete job/deeplog-prom-exporter --timeout=100s -n $APP

    kubectl_run annotate es external-secrets-$APP force-sync=$(date +%s) --overwrite -n $APP
    exit 0
fi

#apply deployment yaml
sed -i "s/CIRCLE_TAG_REPLACE/$TAG/g" apps/$APP/kubernetes/values.yaml
kubectl_run apply -f apps/$APP/kubernetes/values.yaml

# Force sync with Vault Secrets
kubectl_run annotate es external-secrets-$APP force-sync=$(date +%s) --overwrite -n $APP

#check if all deploys were successfull
kubectl get deploy -o name -n $APP | xargs -n1 -t kubectl rollout status -n $APP
