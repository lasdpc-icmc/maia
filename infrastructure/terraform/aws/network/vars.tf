variable "env" {
  type = string
}
variable "resource_name" {
  type = string
}
variable "cidr_block" {
  type = string
}
variable "region" {
  type = string
}
variable "subnet" {
  type = map
  default = {
    private  = 2
    public   = 2
    internal = 2
  }
}
variable "start_cidr_at" {
  default = 0
}
variable "key_pair" {
  type = string
}
variable "newbits" {
  type = string
}
variable "zones" {
  type    = string
  default = 4
}
