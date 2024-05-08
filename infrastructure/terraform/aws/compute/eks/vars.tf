variable "env" {
  type = string
}
variable "key_pair" {
  type = string
}
variable "region" {
  type = string
}
variable "resource_name" {
  type = string
}
variable "vpc_name" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "max_size" {
  type = string
}
variable "min_size" {
  type = string
}
variable "desired_capacity" {
  type = string
}
variable "spot_instance_types" {
  type = string
}
variable "max_size_spot" {
  type = string
}
variable "min_size_spot" {
  type = string
}
variable "desired_capacity_spot" {
  type = string
}
variable "root_volume_size" {
  type = string
}
variable "root_volume_type" {
  type = string
}
variable "cluster_version" {
  type = string
}
variable "key" {
  type = string
}
variable "organization" {
  type = string
}
variable "workspace" {
  type = string
}
variable "users" {
  type = list(string)
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = [
    {
      rolearn  = "arn:aws:iam::326123346670:role/karpenter-controller"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]
}