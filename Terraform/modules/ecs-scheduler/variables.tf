variable "image" {
  description = "image from ecr"
  type = string
  default = "801822495646.dkr.ecr.eu-north-1.amazonaws.com/payment-service:latest"
}

variable "container_port" {
  description = "port which container listens on"
  type = number
  default = 8083
}

variable "host_port" {
  description = "port for the host"
  type = number
  default = 8083
}

variable "log_group_name" {
  description = "group name for cloudwatch"
  type = string
  default = "ecs-logs-scheduler"
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
  description = "arn of the task role"
  type = string
}

variable "db_password" {
  description = "password for the database"
  type = string
}

variable "rds_endpoint" {
  description = "endpoint of rds"
  type = string
}