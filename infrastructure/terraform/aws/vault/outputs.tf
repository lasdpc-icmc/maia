output "cluster_endpoint" {
  value = data.aws_eks_cluster.icmc.endpoint
}

output "certificate_authority_data" {
  value = data.aws_eks_cluster.icmc.certificate_authority[0].data
}

output "oidc_provider" {
  value = data.aws_eks_cluster.icmc.identity[0].oidc[0].issuer
}
