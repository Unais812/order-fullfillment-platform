module "vpc" {
  source = "./modules/vpc"
  vpc_endpoint_sg = module.security-groups.vpc_endpoint_sg
}

module "ecs-cluster" {
  source = "./modules/ecs-cluster"
}

module "ecs_services" {
  source = "./modules/ecs-services"
  execution_role_arn = module.iam.execution_role_arn
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
  dashboard_api_target_group = module.alb.dashboard_api_target_group
  api_gateway_target_group = module.alb.api_gateway_target_group
  task_role_arn_api = module.iam.api_gateway_task_role_arn
  task_role_arn_dashboard = module.iam.dashboard_api_task_role_arn
  task_role_arn_inventory = module.iam.inventory_service_task_role_arn
  task_role_arn_notification = module.iam.notification_service_task_role_arn
  task_role_arn_order = module.iam.order_service_task_role_arn
  task_role_arn_payment = module.iam.payment_service_task_role_arn
  task_role_arn_scheduler = module.iam.scheduler_task_role_arn
  task_role_arn_shipping = module.iam.shipping_service_task_role_arn
  task_role_arn_worker = module.iam.worker_task_role_arn
  service_discovery_arn_api = module.vpc.service_discovery_arns
  service_discovery_arn_dashboard = module.vpc.service_discovery_arns["dashboard-api"]
  service_discovery_arn_inventory = module.vpc.service_discovery_arns["inventory-service"]
  service_discovery_arn_notification = module.vpc.service_discovery_arns["notification-service"]
  service_discovery_arn_order = module.vpc.service_discovery_arns["order-service"]
  service_discovery_arn_payment = module.vpc.service_discovery_arns["payment-service"]
  service_discovery_arn_shipping = module.vpc.service_discovery_arns["shipping-service"]
  db_password = var.db_password
  rds_endpoint = module.database.rds_endpoint
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
  vpc_id = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids["1"]
  igw_id = module.vpc.igw_id
  ecs_sg = module.security-groups.ecs_sg
}

module "route53" {
  source = "./modules/route53"
  alb_dns = module.alb.alb_dns
  alb_zone_id = module.alb.alb_zone_id
  
}

