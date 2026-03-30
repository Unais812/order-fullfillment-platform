module "vpc" {
  source = "./modules/vpc"
}

module "secret" {
  source = "./modules/secrets"
  db_password = var.db_password
  jwt_secret  = var.jwt_secret
}

module "ecs" {
  source = "./modules/ecs"
  execution_role_arn = module.iam.execution_role_arn
  api_gateway_target_group = module.alb.api_gateway_target_group
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id
}

module "security-groups" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.vpc_id
}