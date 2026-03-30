module "vpc" {
  source = "./modules/vpc"
  vpc_endpoint_sg = module.security-groups.vpc_endpoint_sg
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
  ecs_sg = module.security-groups.ecs_sg
  private_subnet_ids = module.vpc.private_subnet_ids
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
}