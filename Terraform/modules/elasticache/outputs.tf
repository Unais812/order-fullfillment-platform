# cant use arn for connection, have to use endpoint
output "elasticache_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}
