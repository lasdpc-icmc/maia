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
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.5.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.10.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }

  required_version = ">= 1.3.9"
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