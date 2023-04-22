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
  required_version = ">= 0.12.24"
  backend "s3" {
    bucket  = "lasdpc-terraform-states"
    key     = "aws/s3/terraform.tfstate"
    region  = "us-east-1"
  }
}