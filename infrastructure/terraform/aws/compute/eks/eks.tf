data "aws_caller_identity" "this" {}

data "aws_eks_cluster" "cluster" {
  name = module.aws_eks.cluster_id
}
data "aws_eks_cluster_auth" "cluster" {
  name = module.aws_eks.cluster_id
}
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "1.11.1"
}

module "aws_eks" {
  source          = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v16.0.0"
  cluster_name    = "${var.env}-${var.resource_name}"
  subnets         = data.terraform_remote_state.vpc.outputs.pub_sn_id
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  cluster_version = var.cluster_version

  worker_groups = [{
    asg_desired_capacity  = var.desired_capacity
    asg_max_size          = var.max_size
    asg_min_size          = var.min_size
    instance_type         = var.instance_type
    spot_price            = var.spot_price
    root_volume_size      = var.root_volume_size
    root_volume_type      = var.root_volume_type
    key_name              = var.key_pair
    ebs_optimized         = true
    public_ip             = false
    autoscaling_enabled   = true
    protect_from_scale_in = true
    subnets               = data.terraform_remote_state.vpc.outputs.priv_sn_id
  },
  {
    asg_desired_capacity  = "1"
    asg_max_size          = "2"
    asg_min_size          = "1"
    instance_type         = "r6a.8xlarge"
    spot_price            = var.spot_price
    root_volume_size      = "120"
    root_volume_type      = var.root_volume_type
    key_name              = var.key_pair
    ebs_optimized         = true
    public_ip             = false
    autoscaling_enabled   = true
    protect_from_scale_in = true
    subnets               = data.terraform_remote_state.vpc.outputs.priv_sn_id
  }]

  tags = local.common_tags
   map_users = [
    {
      userarn  = "arn:aws:iam::326123346670:user/aws-eks-circleci"
      username = "circleci-deploy"
      groups   = ["system:masters"]
    }
  ]
}

resource "aws_key_pair" "prod" {
  key_name   = var.env
  public_key = var.key
}