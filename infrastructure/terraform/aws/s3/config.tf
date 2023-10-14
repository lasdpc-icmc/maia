locals {
  common_tags = {
    "application" = var.resource_name
    "environment" = var.env
    "team"        = "icmc"
    "project"     = "platform"
  }
}

provider "aws" {
  alias  = "aws-s3-US"
  region = var.region
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

terraform {
  required_version = ">= 0.12.24"
}