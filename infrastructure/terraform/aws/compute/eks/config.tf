locals {
  common_tags = {
    "application" = "kubernetes"
    "environment" = var.env
    "team"        = "icmc"
    "project"     = "platform"
  }
}

provider "aws" {
  alias  = "aws-eks-US"
  region = var.region
}

terraform {
  required_version = ">= 0.12.24"
  backend "s3" {
    bucket = "lasdpc-terraform-states"
    key    = "aws/compute/eks/kubernetes/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  alias      = "aws-mock"
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"

  endpoints {
    s3       = "http://s3.localhost.localstack.cloud:4566"
    dynamodb = "http://dynamodb.localhost.localstack.cloud:4566"
    lambda   = "http://lambda.localhost.localstack.cloud:4566"
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
