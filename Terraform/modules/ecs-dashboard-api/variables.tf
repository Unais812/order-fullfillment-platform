variable "image" {
  description = "image for the api-gateway"
  type = string
  default = "801822495646.dkr.ecr.eu-north-1.amazonaws.com/dashboard-api@sha256:f0bea5e3e4573fa8cf8c10ee8f577c6c55276af02a929190e028d3a0f3f703d9"
}

variable "container_port" {
  description = "port which container listens on"
  type = number
  default = 8086
}

variable "host_port" {
  description = "port for the host"
  type = number
  default = 8086
}

variable "log_group_name" {
  description = "group name for cloudwatch"
  type = string
  default = "ecs-logs-dashboard-api"
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