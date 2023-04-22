resource "aws_elasticache_cluster" "lasdpc-icmc" {
  cluster_id           = "${var.app_name}-${var.env}"
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = 1
  parameter_group_name = var.parameter_group_name
  engine_version       = "7.0.7"
  port                 = var.redis_port
  tags                 = local.common_tags
}