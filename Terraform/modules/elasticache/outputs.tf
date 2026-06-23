# cant use arn for connection, have to use endpoint
output "elasticache_endpoint" {
  value = "redis://${aws_elasticache_cluster.redis.cache_nodes[0].address}:6379"
}
