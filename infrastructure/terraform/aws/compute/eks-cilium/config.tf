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
    bucket = "lasdpc-terraform-states"
    key    = "aws/compute/eks-cilium/kubernetes/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = "${var.organization}"
    workspaces = {
      name = "${var.workspace}"
    }
  }
}
