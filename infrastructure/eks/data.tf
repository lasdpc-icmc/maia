data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = "${var.organization}"
    workspaces = {
      name = "${var.workspace}"
    }
  }
}

data "aws_caller_identity" "current" {}