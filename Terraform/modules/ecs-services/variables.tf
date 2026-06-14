variable "image_api" {
  description = "image for the api-gateway"
  type = string
  default = "801822495646.dkr.ecr.eu-north-1.amazonaws.com/api-gateway:latest"
}

variable "container_port_api" {
  description = "port which container listens on"
  type = number
  default = 8080
}

variable "host_port_api" {
  description = "port for the host"
  type = number
  default = 8080
}

variable "log_group_name_api" {
  description = "group name for cloudwatch"
  type = string
  default = "ecs-logs"
}

variable "task_role_arn_api" {
  description = "arn of the api task role"
  type = string
}

variable "service_discovery_arn_api" {
  description = "arn of the service discovery"
  type = string
}

variable "api_gateway_target_group" {
  description = "arn of the api gateway target group for alb"
  type = string
}

///// Dashboard-service /////

variable "image_dashboard" {
  description = "image for the dashboard service"
  type = string
  default = "801822495646.dkr.ecr.eu-north-1.amazonaws.com/dashboard-api:latest"
}

variable "container_port_dashboard" {
  description = "port which dashboard container listens on"
  type = number
  default = 8086
}

variable "host_port_dashboard" {
  description = "port for the host"
  type = number
  default = 8086
}

variable "log_group_name_dashboard" {
  description = "group name for cloudwatch"
  type = string
  default = "ecs-logs-dashboard-api"
}

variable "service_discovery_arn_dashboard" {
  description = "arn of the service discovery for dashboard service"
  type = string
}

variable "task_role_arn_dashboard" {
  description = "arn of the dashboard task role"
  type = string
}

variable "dashboard_api_target_group" {
  description = "target group for the dashboard api service"
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

///// Inventory-service /////

variable "image_inventory" {
  description = "image for the inventory service"
  type = string
  default = "801822495646.dkr.ecr.eu-north-1.amazonaws.com/inventory-service:latest"
}

variable "container_port_inventory" {
  description = "port which inventory container listens on"
  type = number
  default = 8082
}

variable "host_port_inventory" {
  description = "port for the host"
  type = number
  default = 8082
}

variable "log_group_name_inventory" {
  description = "group name for cloudwatch"
  type = string
  default = "ecs-logs-inventory-service"
}

variable "service_discovery_arn_inventory" {
  description = "arn of the service discovery for inventory service"
  type = string
}

variable "task_role_arn_inventory" {
  description = "arn of the inventory task role"
  type = string
}

///// Notification-service /////

variable "image_notification" {
  description = "image for the notification service"
  type = string
  default = "801822495646.dkr.ecr.eu-north-1.amazonaws.com/notification-service:latest"
}

variable "container_port_notification" {
  description = "port which notification container listens on"
  type = number
  default = 8084
}

variable "host_port_notification" {
  description = "port for the host"
  type = number
  default = 8084
}

variable "log_group_name_notification" {
  description = "group name for cloudwatch"
  type = string
  default = "ecs-logs-notification-service"
}

variable "service_discovery_arn_notification" {
  description = "arn of the service discovery for notification service"
  type = string
}

variable "task_role_arn_notification" {
  description = "arn of the notification task role"
  type = string
}

///// Order-service /////

variable "image_order" {
  description = "image for the order service"
  type = string
  default = "801822495646.dkr.ecr.eu-north-1.amazonaws.com/order-service:latest"
}

variable "container_port_order" {
  description = "port which order container listens on"
  type = number
  default = 8081
}

variable "host_port_order" {
  description = "port for the host"
  type = number
  default = 8081
}

variable "log_group_name_order" {
  description = "group name for cloudwatch"
  type = string
  default = "ecs-logs-order-service"
}

variable "service_discovery_arn_order" {
  description = "arn of the service discovery for order service"
  type = string
}

variable "task_role_arn_order" {
  description = "the arn for the task role for order service"
  type = string
}

///// Payment-service /////

variable "image_payment" {
  description = "image for payment service"
  type = string
  default = "801822495646.dkr.ecr.eu-north-1.amazonaws.com/payment-service:latest"
}

variable "container_port_payment" {
  description = "port which payment container listens on"
  type = number
  default = 8083
}

variable "host_port_payment" {
  description = "port for the host"
  type = number
  default = 8083
}

variable "log_group_name_payment" {
  description = "group name for cloudwatch"
  type = string
  default = "ecs-logs-payment-service"
}

variable "service_discovery_arn_payment" {
  description = "arn of the service discovery for payment service"
  type = string
}

variable "task_role_arn_payment" {
  description = "the arn for the task role for payment service"
  type = string
}

///// Scheduler-service /////

variable "image_scheduler" {
  description = "image for scheduler service"
  type = string
  default = "801822495646.dkr.ecr.eu-north-1.amazonaws.com/scheduler-service:latest"
}

variable "container_port_scheduler" {
  description = "port which scheduler container listens on"
  type = number
  default = 8083
}

variable "host_port_scheduler" {
  description = "port for the host"
  type = number
  default = 8083
}

variable "log_group_name_scheduler" {
  description = "group name for cloudwatch"
  type = string
  default = "ecs-logs-scheduler"
}

variable "task_role_arn_scheduler" {
  description = "arn of the scheduler task role"
  type = string
}

///// Shipping-service /////

variable "image_shipping" {
  description = "image for shipping service"
  type = string
  default = "801822495646.dkr.ecr.eu-north-1.amazonaws.com/shipping-service:latest"
}

variable "container_port_shipping" {
  description = "port which shipping container listens on"
  type = number
  default = 8085
}

variable "host_port_shipping" {
  description = "port for the host"
  type = number
  default = 8085
}

variable "log_group_name_shipping" {
  description = "group name for cloudwatch"
  type = string
  default = "ecs-logs-shipping-service"
}

variable "service_discovery_arn_shipping" {
  description = "arn of the service discovery for shipping service"
  type = string
}

variable "task_role_arn_shipping" {
  description = "the arn for the task role for shipping service"
  type = string
}

///// Worker-service /////

variable "image_worker" {
  description = "image for worker service"
  type = string
  default = "801822495646.dkr.ecr.eu-north-1.amazonaws.com/worker:latest"
}

variable "container_port_worker" {
  description = "port which worker container listens on"
  type = number
  default = 8085
}

variable "host_port_worker" {
  description = "port for the host"
  type = number
  default = 8085
}

variable "log_group_name_worker" {
  description = "group name for cloudwatch"
  type = string
  default = "ecs-logs-worker"
}

variable "task_role_arn_worker" {
  description = "the arn for the task role for worker service"
  type = string
}

///// Multiple /////

variable "logstream_prefix" {
  description = "logstream prefix"
  type        = string
  default     = "ecs"
}

variable "log_days" {
  description = "retention in days for cloudwatch logs"
  type = number
  default = 7
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

variable "jwt_secret_arn" {
  description = "jwt secret"
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

variable "dashboard_service_url" {
  description = "url for the dashboard service"
  type = string
}

variable "elasticache_url" {
  description = "url for elasticache"
  type = string
}