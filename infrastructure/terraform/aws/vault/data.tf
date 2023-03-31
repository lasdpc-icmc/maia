data "aws_caller_identity" "caller_identity" {}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}
data "tls_certificate" "cert" {
  url = var.oidc_provider
}