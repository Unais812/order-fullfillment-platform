resource "aws_elasticache_subnet_group" "redis" {
  name       = "ecs-v3-redis-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "ecs-v3-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"  
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [var.redis_sg]
}