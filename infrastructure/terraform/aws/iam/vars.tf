variable "username" {
  type = list(string)
}
variable "username_dev" {
  type = list(string)
}
variable "username_read_only" {
  type = list(string)
}
variable "env" {
  type = string
}
variable "resource_name" {
  type = string
}
variable "region" {
  type = string
}

variable "bucket_states_name"{
  type = string
}

variable "bucket_gatling_name"{
  type = string
}
variable "bucket_locust_name"{
  type = string
}

variable "oidc_provider" {
  type = string
}
