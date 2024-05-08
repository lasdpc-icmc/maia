data "aws_caller_identity" "caller_identity" {}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}

data "tls_certificate" "cert" {
  url = data.aws_eks_cluster.icmc.identity[0].oidc[0].issuer
}

data "aws_eks_cluster" "icmc" {
  name = var.cluster_id
}