locals {
  common_tags = {
    "application" = var.resource_name
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
  required_version = ">= 0.12.24"
  backend "s3" {
    bucket  = "terraform-lasdpc-states"
    key     = "aws/iam/terraform.tfstate"
    region  = "us-east-1"
  }
}

data "aws_availability_zones" "available" {}
