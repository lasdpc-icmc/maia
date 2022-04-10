locals {
  common_tags = {
    "application" = "kubernetes"
    "environment" = var.env
    "team"        = "icmc"
    "project"     = "platform"
  }
}

provider "aws" {
  region  = "us-east-1"
  version = "3.64.0"
}

terraform {
  required_version = ">= 0.12.24"
  backend "s3" {
    bucket  = "terraform-metrics-application"
    key     = "aws/compute/eks/kubernetes/terraform.tfstate"
    region  = "us-east-1"
  }
}

data "terraform_remote_state" "network" {
  backend   = "s3"
  config    = {
    bucket  = "terraform-metrics-application"
    key     = "aws/network/vpc/terraform.tfstate"
    region  = "us-east-1"
  }
}
