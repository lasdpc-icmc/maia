data "aws_caller_identity" "this" {}

data "aws_eks_cluster" "cluster" {
  name = module.aws_eks.cluster_id
}
data "aws_eks_cluster_auth" "cluster" {
  name = module.aws_eks.cluster_id
}

locals {
  auth_users = [
    for user in var.users :
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:user/${user}"
      username = user
      groups   = ["system:masters"]
    }
  ]
}

module "aws_eks" {
  source          = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v16.0.0"
  cluster_name    = "${var.env}-${var.resource_name}"
  subnets         = data.terraform_remote_state.vpc.outputs.pub_sn_id
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  cluster_version = var.cluster_version
  enable_irsa     = true

  worker_groups = [{
    asg_desired_capacity  = var.desired_capacity
    asg_max_size          = var.max_size
    asg_min_size          = var.min_size
    instance_type         = var.instance_type
    root_volume_size      = var.root_volume_size
    root_volume_type      = var.root_volume_type
    key_name              = var.key_pair
    ebs_optimized         = true
    public_ip             = false
    autoscaling_enabled   = true
    protect_from_scale_in = true
    subnets               = data.terraform_remote_state.vpc.outputs.priv_sn_id
  }]

  node_groups = {
    icmc-spot = {
      desired_capacity = var.desired_capacity_spot
      max_capacity     = var.max_size_spot
      min_capacity     = var.min_size_spot

      instance_types = [var.spot_instance_types]
      capacity_type  = "SPOT"
      k8s_labels = {
        Environment = var.env
        name        = var.resource_name
        ec2_type    = "spot"
      }
      additional_tags = {
        ec2_type = "spot"
      }
    }
  }

  tags = local.common_tags

  map_roles = var.map_roles

  map_users = concat([
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:user/aws-eks-circleci"
      username = "circleci-deploy"
      groups   = ["system:masters"]
    }
  ], local.auth_users)
}

resource "aws_key_pair" "prod" {
  key_name   = var.env
  public_key = var.key
}