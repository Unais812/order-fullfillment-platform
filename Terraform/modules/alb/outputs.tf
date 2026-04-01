output "api_gateway_target_group" {
  value = aws_lb_target_group.api-gateway.arn
}
