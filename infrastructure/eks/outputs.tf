output "oidc_provider" {
  description = "oidc_provider"
  value       = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  description = "oidc_provider_arn"
  value       = module.eks.oidc_provider_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}