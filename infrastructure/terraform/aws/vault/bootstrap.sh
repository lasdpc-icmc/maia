#!/bin/bash
set -o xtrace

B64_CLUSTER_CA=${data.aws_eks_cluster.cluster.certificate_authority.0.data}
API_SERVER_URL=${data.aws_eks_cluster.cluster.endpoint}

/etc/eks/bootstrap.sh ${var.resource_name-$var.environment} --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL
