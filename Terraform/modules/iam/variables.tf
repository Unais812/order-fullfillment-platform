variable "secrets_policy_arn" {
  description = "policy which allows access to secrets manager"
  type = string
  default = "arn:aws:iam::aws:policy/AWSSecretsManagerClientReadOnlyAccess"
}

variable "task_execution_policy_arn" {
  description = "arn of the task execution policy to allow access to ECR and CloudWatch"
  type = string
  default = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  type        = string
}