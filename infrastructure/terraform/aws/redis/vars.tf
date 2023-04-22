variable "app_name" {
  type = string
}
variable "region" {
  type = string
}
variable "env" {
  type = string
}
variable "node_type" {
  type = string
}
variable "redis_port" {
  type = string
}
variable "parameter_group_name" {
  type = string
}
variable "subnet_group_name" {
  type = string
}
variable "engine_version" {
  type = string
}
variable "num_cache_nodes" {
  type = string
}
variable "subnets" {
  type = list
}