output "execution_role_arn" {
  value = aws_iam_role.ecs_execution_iam_role.arn
}

output "order_service_task_role_arn" {
  value = aws_iam_role.order_service_task_role.arn
}

output "payment_service_task_role_arn" {
  value = aws_iam_role.payment_service_task_role.arn
}

output "worker_task_role_arn" {
  value = aws_iam_role.worker_service_task_role.arn
}

output "inventory_service_task_role_arn" {
  value = aws_iam_role.inventory_service_task_role.arn
}

output "scheduler_task_role_arn" {
  value = aws_iam_role.scheduler_service_task_role.arn
}

output "dashboard_api_task_role_arn" {
  value = aws_iam_role.dashboard_api_task_role.arn
}

output "api_gateway_task_role_arn" {
  value = aws_iam_role.api_gateway_task_role.arn
}

output "shipping_service_task_role_arn" {
  value = aws_iam_role.shipping_service_task_role.arn
}

output "notification_service_task_role_arn" {
  value = aws_iam_role.notification_service_task_role.arn
}