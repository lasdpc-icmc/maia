variable "region" {
  type        = string
  description = "AWS region where the provider will operate."
}

variable "resource_name" {
  type        = string
  description = "A name for the AWS resource being provisioned."
}

variable "environment" {
  type        = string
  description = "The environment in which the infrastructure is deployed (e.g., 'production', 'development')."
}

variable "addon_version" {
  type        = string
  description = "Version of the addon to be installed."
}

variable "instance_types_on_demand" {
  type        = list(any)
  description = "List of on-demand instance types."
}

variable "instance_types_spot" {
  type        = list(any)
  description = "List of spot instance types."
}

variable "volume_size" {
  type        = number
  description = "Size of the storage volume."
}

variable "iops" {
  type        = number
  description = "Input/output operations per second for storage volume."
}

variable "throughput" {
  type        = number
  description = "Throughput for storage volume."
}

variable "volume_type" {
  type        = string
  description = "Type of storage volume (e.g., 'gp2', 'io1')."
}

variable "cluster_version" {
  type        = string
  description = "Version of the cluster."
}

variable "min_size_spot" {
  type        = number
  description = "Minimum size for spot instances."
}

variable "max_size_spot" {
  type        = number
  description = "Maximum size for spot instances."
}

variable "desired_size_spot" {
  type        = number
  description = "Desired size for spot instances."
}

variable "min_size_ondemand" {
  type        = number
  description = "Minimum size for on-demand instances."
}

variable "max_size_ondemand" {
  type        = number
  description = "Maximum size for on-demand instances."
}

variable "desired_size_ondemand" {
  type        = number
  description = "Desired size for on-demand instances."
}

variable "aws_account_id" {
  type        = number
  description = "AWS account ID."
}

variable "role_arn" {
  type        = string
  description = "ARN of the IAM Role to assume."
}

variable "web_identity_token" {
  type        = string
  sensitive   = true
  description = "Value of a web identity token from an OpenID Connect (OIDC) or OAuth provider."
}

variable "remote_state_address" {
  type        = string
  description = "Address information (e.g., IP address, DNS) for the resource."
}

variable "gitlab_username" {
  type        = string
  description = "Username for accessing the resource."
}

variable "gitlab_access_token" {
  type        = string
  description = "Password for accessing the resource."
}

variable "grafana_client_id" {
  type        = string
  description = "Grafana Client ID Token."
}

variable "grafana_client_secret" {
  type        = string
  description = "Grafana Secret ID Token."
}

variable "vault_client_id" {
  type        = string
  description = "Vault Client ID Token."
}

variable "vault_client_secret" {
  type        = string
  description = "Vault Secret ID Token."
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = optional(string, null)
    username = string
    groups   = list(string)
  }))
}

variable "aws_auth_users" {
  description = "Additional usernames to add to the aws-auth configmap."
  type = list(object({
    userarn  = optional(string)
    username = optional(string)
    groups   = optional(list(string))
  }))
  default = []
}

variable "gitlab_token" {
  type        = string
  sensitive   = true
  description = "Token to use to authenticate against the GitLab API. It requires api and read_repository permissions."
}

variable "argocd_client_id" {
  type        = string
  sensitive   = true
  description = "Client to be used to config the ArgoCD SSO integration"
}

variable "argocd_client_secret" {
  type        = string
  sensitive   = true
  description = "Client Secret to be used to config the ArgoCD SSO integration"
}