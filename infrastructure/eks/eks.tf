locals {
  tags = {
    Name   = var.resource_name
    Env    = var.environment
    Region = var.region
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.20.0"

  cluster_name                   = var.resource_name
  cluster_endpoint_public_access = true
  cluster_version                = var.cluster_version

  cluster_addons = {

    coredns = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "45m"
        delete = "30m"
      }
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      addon_version     = var.addon_version
      resolve_conflicts = "OVERWRITE"
      configuration_values = jsonencode({
        env = {
          WARM_IP_TARGET    = "11"
          MINIMUM_IP_TARGET = "20"
        }
      })
    }
  }

  create_kms_key = false
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = module.kms.key_arn
  }

  iam_role_additional_policies = {
    additional = aws_iam_policy.additional.arn
  }

  vpc_id                   = data.terraform_remote_state.vpc.outputs.vpc_id
  control_plane_subnet_ids = [data.terraform_remote_state.vpc.outputs.priv_sn_id[3], data.terraform_remote_state.vpc.outputs.priv_sn_id[4], data.terraform_remote_state.vpc.outputs.priv_sn_id[5]]
  subnet_ids               = [data.terraform_remote_state.vpc.outputs.priv_sn_id[0], data.terraform_remote_state.vpc.outputs.priv_sn_id[1], data.terraform_remote_state.vpc.outputs.priv_sn_id[2]]

  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }

    ingress_source_security_group_id = {
      description              = "Ingress from another computed security group"
      protocol                 = "tcp"
      from_port                = 22
      to_port                  = 22
      type                     = "ingress"
      source_security_group_id = aws_security_group.additional.id
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    ingress_source_security_group_id = {
      description              = "Ingress from another computed security group"
      protocol                 = "tcp"
      from_port                = 22
      to_port                  = 22
      type                     = "ingress"
      source_security_group_id = aws_security_group.additional.id
    }
  }

  self_managed_node_group_defaults = {
    vpc_security_group_ids = [aws_security_group.additional.id]
    iam_role_additional_policies = {
      additional = aws_iam_policy.additional.arn
    }

    instance_refresh = {
      strategy = "Rolling"
      preferences = {
        min_healthy_percentage = 66
      }
    }
  }

  eks_managed_node_groups = {
    "${var.resource_name}-spot" = {
      min_size     = var.min_size_spot
      max_size     = var.max_size_spot
      desired_size = var.desired_size_spot

      instance_types = var.instance_types_spot
      subnet_ids     = [data.terraform_remote_state.vpc.outputs.priv_sn_id[0], data.terraform_remote_state.vpc.outputs.priv_sn_id[1], data.terraform_remote_state.vpc.outputs.priv_sn_id[2]]
      capacity_type  = "SPOT"
      labels = {
        type = "spot"
      }

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.volume_size
            volume_type           = var.volume_type
            iops                  = var.iops
            throughput            = var.throughput
            delete_on_termination = true
          }
        }
      }

      update_config = {
        max_unavailable_percentage = 33
      }

      tags = {
        type = "spot"
      }
    }

    "${var.resource_name}-ondemand" = {
      min_size     = var.min_size_ondemand
      max_size     = var.max_size_ondemand
      desired_size = var.desired_size_ondemand

      instance_types = var.instance_types_on_demand
      subnet_ids     = [data.terraform_remote_state.vpc.outputs.priv_sn_id[0], data.terraform_remote_state.vpc.outputs.priv_sn_id[1], data.terraform_remote_state.vpc.outputs.priv_sn_id[2]]
      capacity_type  = "ONDEMAND"
      labels = {
        type = "ondemand"
      }

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.volume_size
            volume_type           = var.volume_type
            iops                  = var.iops
            throughput            = var.throughput
            delete_on_termination = true
          }
        }
      }

      update_config = {
        max_unavailable_percentage = 33
      }

      tags = {
        type = "ondemand"
      }
    }
  }

  manage_aws_auth_configmap = true

  # aws_auth_node_iam_role_arns_non_windows = [
  #   module.eks_managed_node_group.iam_role_arn
  # ]

  # aws_auth_roles = concat([
  #   {
  #     rolearn  = module.eks_managed_node_group.iam_role_arn
  #     username = "system:node:{{EC2PrivateDNSName}}"
  #     groups = [
  #       "system:bootstrappers",
  #       "system:nodes",
  #     ]
  #   }
  # ], var.map_roles)

  aws_auth_users = var.aws_auth_users

  aws_auth_accounts = [
    "${var.aws_account_id}"
  ]

  tags = local.tags
}

resource "aws_security_group" "additional" {
  name_prefix = "${local.tags.Name}-additional"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id


  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      data.terraform_remote_state.vpc.outputs.cidr_block
    ]
  }

  tags = merge(local.tags, { Name = "${local.tags.Name}-additional" })
}

resource "aws_iam_policy" "additional" {
  name = "${local.tags.Name}-additional"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "2.1.0"

  aliases               = ["eks/${local.tags.Name}"]
  description           = "${local.tags.Name} cluster encryption key"
  enable_default_policy = true
  key_owners            = [data.aws_caller_identity.current.arn]
  tags                  = local.tags
}