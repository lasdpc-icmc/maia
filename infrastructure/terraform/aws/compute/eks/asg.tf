resource "aws_launch_configuration" "default" {
  name_prefix          = "on-demand-${var.env}-${var.resource_name}-"
  image_id             = module.aws_eks.workers_default_ami_id
  instance_type        = var.instance_type
  security_groups      = [module.aws_eks.worker_security_group_id]
  iam_instance_profile = module.aws_eks.worker_iam_instance_profile_names[0]
  user_data            = module.aws_eks.workers_user_data[0]
  key_name             = var.key_pair
  ebs_optimized        = "true"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = true
  }
}

resource "aws_autoscaling_group" "default" {
  name_prefix          = "on-demand-${var.env}-${var.resource_name}-"
  min_size             = var.min_size_on_demand
  max_size             = var.max_size_on_demand
  desired_capacity     = var.desired_capacity_on_demand
  launch_configuration = aws_launch_configuration.default.name
  vpc_zone_identifier  = data.terraform_remote_state.network.outputs.int_sn_id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_launch_configuration.default]

  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = "${var.env}-${var.resource_name}"
        "propagate_at_launch" = true
      },
      {
        "key"                 = "k8s.io/cluster-autoscaler/enabled"
        "value"               = "true"
        "propagate_at_launch" = false
      },
      {
        "key"                 = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
        "value"               = "32Gi"
        "propagate_at_launch" = false
      },
      {
        "key"                 = "k8s.io/cluster-autoscaler/${var.env}-${var.resource_name}"
        "value"               = "${var.env}-${var.resource_name}"
        "propagate_at_launch" = false
      },
      {
        "key"                 = "k8s.io/cluster/${var.env}-${var.resource_name}"
        "value"               = "owned"
        "propagate_at_launch" = true
      },
      {
        "key"                 = "kubernetes.io/cluster/${var.env}-${var.resource_name}"
        "value"               = "owned"
        "propagate_at_launch" = true
      },
    ],
  )
}
