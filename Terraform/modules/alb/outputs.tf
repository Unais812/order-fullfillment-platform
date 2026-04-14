output "api_gateway_target_group" {
  value = aws_lb_target_group.api-gateway.arn
}

output "dashboard_api_target_group" {
  value = aws_lb_target_group.dashboard-api.arn
}