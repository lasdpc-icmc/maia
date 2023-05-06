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

if [ $APP == "locust-metrics-distributor" ]; then
    sed -i "s|LOCUST_DIST_SECRET_KEY_REPLACE|$LOCUST_DIST_SECRET_KEY_REPLACE|g" \
        apps/$APP/kubernetes/values.yaml
    sed -i "s|LOCUST_DIST_KEY_ID_REPLACE|$LOCUST_DIST_KEY_ID_REPLACE|g" \
        apps/$APP/kubernetes/values.yaml
elif [ $APP == "deep-log" ]; then
    sed -i "s/CIRCLE_TAG_REPLACE/$TAG/g" apps/$APP/kubernetes/applications/values.yaml
    kubectl_run delete job deep-log-training -n $APP
    kubectl_run apply -f apps/$APP/kubernetes/applications/values.yaml
    #check if all deploys were successfull\
    kubectl_run wait --for=condition=complete job/deep-log-training -n $APP
    break
fi

#apply deployment yaml
sed -i "s/CIRCLE_TAG_REPLACE/$TAG/g" apps/$APP/kubernetes/values.yaml
kubectl_run apply -f apps/$APP/kubernetes/values.yaml

#check if all deploys were successfull
kubectl get deploy -o name -n $APP | xargs -n1 -t kubectl rollout status -n $APP