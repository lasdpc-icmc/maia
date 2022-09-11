variable "env" {
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
variable "min_size_on_demand" {
  type = string
}
variable "max_size_on_demand" {
  type = string
}
variable "desired_capacity" {
  type = string
}
variable "desired_capacity_on_demand" {
  type = string
}
variable "spot_price" {
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