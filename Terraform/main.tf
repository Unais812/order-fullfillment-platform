module "vpc" {
  source = "./modules/vpc"
  vpc_endpoint_sg = module.security-groups.vpc_endpoint_sg
}

module "ecs-cluster" {
  source = "./modules/ecs-cluster"
}

module "ecs-api-gatewway" {
  source = "./modules/ecs-api-gateway"
  execution_role_arn = module.iam.execution_role_arn
  api_gateway_target_group = module.alb.api_gateway_target_group
  ecs_sg = module.security-groups.ecs_sg
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_cluster_id = module.ecs-cluster.ecs_cluster_id
  jwt_secret_arn = var.jwt_secret
  inventory_service_url = module.vpc.service_discovery_urls["inventory-service"]
  order_service_url = module.vpc.service_discovery_urls["order-service"]
  payment_service_url = module.vpc.service_discovery_urls["payment-service"]
  notification_service_url = module.vpc.service_discovery_urls["notification-service"]
  shipping_service_url = module.vpc.service_discovery_urls["shipping-service"]
  dashboard_service_url = module.vpc.service_discovery_urls["dashboard-api"]
  elasticache_url = module.elasticache.elasticache_endpoint
  sqs_queue_url = module.sqs.queue_url
  task_role_arn = module.iam.api_gateway_task_role_arn
  service_discovery_arn = module.vpc.service_discovery_arns["dashboard-api"]

}

module "ecs-dashboard-api" {
  source = "./modules/ecs-dashboard-api"
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_cluster_id = module.ecs-cluster.ecs_cluster_id
  execution_role_arn = module.iam.execution_role_arn
  ecs_sg = module.security-groups.ecs_sg
  service_discovery_arn = module.vpc.service_discovery_arns["dashboard-api"]
  task_role_arn = module.iam.dashboard_api_task_role_arn
  dashboard_api_target_group = module.alb.dashboard_api_target_group
  db_password = var.db_password
  rds_endpoint = module.database.rds_endpoint
}

module "ecs-inventory-service" {
  source = "./modules/ecs-inventory-service"
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_cluster_id = module.ecs-cluster.ecs_cluster_id
  execution_role_arn = module.iam.execution_role_arn
  ecs_sg = module.security-groups.ecs_sg
  service_discovery_arn = module.vpc.service_discovery_arns["inventory-service"]
  task_role_arn = module.iam.inventory_service_task_role_arn
  db_password = var.db_password
  rds_endpoint = module.database.rds_endpoint
}

module "notification-service" {
  source = "./modules/ecs-notification-service"
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_cluster_id = module.ecs-cluster.ecs_cluster_id
  execution_role_arn = module.iam.execution_role_arn
  ecs_sg = module.security-groups.ecs_sg
  service_discovery_arn = module.vpc.service_discovery_arns["notification-service"]
  task_role_arn = module.iam.notification_service_task_role_arn
  db_password = var.db_password
  rds_endpoint = module.database.rds_endpoint
}

module "order-service" {
  source = "./modules/ecs-order-service"
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_cluster_id = module.ecs-cluster.ecs_cluster_id
  execution_role_arn = module.iam.execution_role_arn
  ecs_sg = module.security-groups.ecs_sg
  service_discovery_arn = module.vpc.service_discovery_arns["order-service"]
  task_role_arn = module.iam.order_service_task_role_arn
  sqs_queue_url = module.sqs.queue_url
  db_password = var.db_password
  rds_endpoint = module.database.rds_endpoint

}

module "payment-service" {
  source = "./modules/ecs-payment-service"
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_cluster_id = module.ecs-cluster.ecs_cluster_id
  execution_role_arn = module.iam.execution_role_arn
  ecs_sg = module.security-groups.ecs_sg
  service_discovery_arn = module.vpc.service_discovery_arns["payment-service"]
  task_role_arn = module.iam.payment_service_task_role_arn
  sqs_queue_url = module.sqs.queue_url
  db_password = var.db_password
  rds_endpoint = module.database.rds_endpoint
}

module "scheduler-service" {
  source = "./modules/ecs-scheduler"
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_cluster_id = module.ecs-cluster.ecs_cluster_id
  execution_role_arn = module.iam.execution_role_arn
  ecs_sg = module.security-groups.ecs_sg
  task_role_arn = module.iam.scheduler_task_role_arn
  db_password = var.db_password
  rds_endpoint = module.database.rds_endpoint
}

module "shipping-service" {
  source = "./modules/ecs-shipping-service"
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_cluster_id = module.ecs-cluster.ecs_cluster_id
  execution_role_arn = module.iam.execution_role_arn
  ecs_sg = module.security-groups.ecs_sg
  service_discovery_arn = module.vpc.service_discovery_arns["shipping-service"]
  task_role_arn = module.iam.shipping_service_task_role_arn
  sqs_queue_url = module.sqs.queue_url
  db_password = var.db_password
  rds_endpoint = module.database.rds_endpoint
}

module "worker" {
  source = "./modules/ecs-worker"
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_cluster_id = module.ecs-cluster.ecs_cluster_id
  execution_role_arn = module.iam.execution_role_arn
  ecs_sg = module.security-groups.ecs_sg
  task_role_arn = module.iam.worker_task_role_arn
  sqs_queue_url = module.sqs.queue_url
  inventory_service_url = module.vpc.service_discovery_urls["inventory-service"]
  order_service_url = module.vpc.service_discovery_urls["order-service"]
  payment_service_url = module.vpc.service_discovery_urls["payment-service"]
  notification_service_url = module.vpc.service_discovery_urls["notification-service"]
  shipping_service_url = module.vpc.service_discovery_urls["shipping-service"]
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  ecs_sg_alb = module.security-groups.ecs_sg_alb
}

module "security-groups" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.vpc_id
}

module "iam" {
  source = "./modules/iam"
  sqs_queue_arn = module.sqs.queue_arn
}

module "database" {
  source = "./modules/database"
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg = module.security-groups.rds_sg
  db_password = var.db_password
}

module "sqs" {
  source = "./modules/sqs"
}

module "elasticache" {
  source = "./modules/elasticache"
  private_subnet_ids = module.vpc.private_subnet_ids
  redis_sg = module.security-groups.elasticache_sg
}

module "observability" {
  source = "./modules/observability"
  private_subnet_ids = module.vpc.private_subnet_ids["2"]
  vpc_id = module.vpc.vpc_id
}