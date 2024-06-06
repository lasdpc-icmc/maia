locals {
  common_tags = {
    "application" = "lasdpc-icmc"
    "environment" = "prod"
    "team"        = "icmc"
    "project"     = "platform"
  }
}

provider "aws" {
  region  = var.region
  version = "3.10.0"
}

terraform {
  required_version = ">= 0.12.24"
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "this" {}