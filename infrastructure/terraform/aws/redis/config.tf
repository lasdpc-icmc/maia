locals {
  common_tags = {
    "application" = var.app_name
    "environment" = var.env
    "team"        = "icmc"
    "project"     = "platform"
  }
}
provider "aws" {
  region  = var.region
  version = "3.10.0"
}
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.64.0"
    }
  }
}