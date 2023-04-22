resource "aws_elasticache_cluster" "lasdpc-icmc" {
  cluster_id           = "${var.app_name}-${var.env}"
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = var.parameter_group_name
  engine_version       = var.engine_version
  port                 = var.redis_port
  tags                 = local.common_tags
  subnet_group_name    = aws_elasticache_subnet_group.lasdpc-vpc.name
  security_group_ids  = [aws_security_group.redis_sg.id]
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