output "execution_role_arn" {
  value = aws_iam_role.ecs_execution_iam_role.arn
}

output "order_service_task_role_arn" {
  value = aws_iam_role.order_service_task_role.arn
}

output "payment_service_task_role_arn" {
  value = aws_iam_role.payment_service_task_role.arn
}

output "shipping_service_task_role_arn" {
  value = aws_iam_role.shipping_service_task_role.arn
}

output "worker_task_role_arn" {
  value = aws_iam_role.worker_task_role.arn
}