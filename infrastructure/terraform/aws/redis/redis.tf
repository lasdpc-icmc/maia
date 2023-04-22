resource "aws_elasticache_subnet_group" "lasdpc-vpc" {
  name       = "${var.app_name}-cache-subnet"
  subnet_ids = [var.subnets]
}

resource "aws_elasticache_replication_group" "lasdpc-icmc" {
  automatic_failover_enabled  = true
  preferred_cache_cluster_azs = ["us-east-1a", "us-east-1b"]
  replication_group_id        = "${var.app_name}-${var.env}"
  description                 = "Redis to store assets from DeepLog Training"
  node_type                   = var.node_type
  num_cache_clusters          = var.num_cache_nodes
  parameter_group_name        = var.parameter_group_name
  port                        = var.redis_port
  security_group_ids          = [aws_security_group.redis_sg.id]
  tags                        = local.common_tags
  subnet_group_name           = aws_elasticache_subnet_group.lasdpc-vpc.name


  lifecycle {
    ignore_changes = [num_cache_clusters]
  }
}

resource "aws_elasticache_cluster" "replica" {
  count = 1
  cluster_id           = "${var.app_name}-${var.env}-${count.index}"
  replication_group_id = aws_elasticache_replication_group.lasdpc-icmc.id
}

resource "aws_security_group" "redis_sg" {
  name        = "${var.app_name}-${var.env}-sg"
  description = "Allow Redis inbound traffic"
  vpc_id      = var.subnet_group_name

  ingress {
    description      = "Redis from VPC"
    from_port        = 6379
    to_port          = 6379
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}