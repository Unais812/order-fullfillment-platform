variable "image" {
  description = "image from ecr"
  type = string
  default = "801822495646.dkr.ecr.eu-north-1.amazonaws.com/worker:latest"
}

variable "container_port" {
  description = "port which container listens on"
  type = number
  default = 8085
}

variable "host_port" {
  description = "port for the host"
  type = number
  default = 8085
}

variable "log_group_name" {
  description = "group name for cloudwatch"
  type = string
  default = "ecs-logs-worker"
}

variable "log_days" {
  description = "retention in days for cloudwatch logs"
  type = number
  default = 7
}

variable "logstream_prefix" {
  description = "logstream prefix"
  type        = string
  default     = "ecs"
}

variable "region" {
  description = "region"
  type = string
  default = "eu-north-1"
}

variable "execution_role_arn" {
  description = "arn of the execution role for ECS"
  type = string
}

variable "ecs_sg" { 
  description = "security group for ecs service"
  type = string
}

variable "private_subnet_ids" {
  description = "ids of the private subnets"
  type = list(string)
}

variable "ecs_cluster_id" {
  description = "id of the cluster"
  type = string
}

variable "task_role_arn" {
  description = "the arn for the task role for order service"
  type = string
}

variable "sqs_queue_url" {
  description = "url for sqs queue"
  type = string
}

variable "order_service_url" {
  description = "url for the order service"
  type = string
}

variable "inventory_service_url" {
  description = "url for the inventory service"
  type = string
}

variable "payment_service_url" {
  description = "url for the payment service"
  type = string
}

variable "notification_service_url" {
  description = "url for the payment service"
  type = string
}

variable "shipping_service_url" {
  description = "url for the shipping service"
  type = string
}