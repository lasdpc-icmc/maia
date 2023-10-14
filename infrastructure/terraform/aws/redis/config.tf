locals {
  common_tags = {
    "application" = var.app_name
    "environment" = var.env
    "team"        = "icmc"
    "project"     = "platform"
  }
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.64.0"
    }
  }
}