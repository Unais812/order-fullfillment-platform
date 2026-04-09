variable "image" {
  description = "image for the api-gateway"
  type = string
  default = "801822495646.dkr.ecr.eu-north-1.amazonaws.com/notification-service:latest"
}

variable "container_port" {
  description = "port which container listens on"
  type = number
  default = 8084
}

variable "host_port" {
  description = "port for the host"
  type = number
  default = 8084
}

variable "log_group_name" {
  description = "group name for cloudwatch"
  type = string
  default = "ecs-logs-notification-service"
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

variable "database_url_secret_arn" {
  description = "database url"
  type = string
  sensitive = true
}

variable "service_discovery_arn" {
  description = "arn of the service discovery"
  type = string
}

variable "task_role_arn" {
  description = "arn of the task role"
  type = string
}