locals {
  subnets = {
    "public-1"  = { cidr = "10.0.1.0/24", az = "eu-north-1a", public = true  }
    "public-2"  = { cidr = "10.0.2.0/24", az = "eu-north-1b", public = true  }
    "private-1" = { cidr = "10.0.3.0/24", az = "eu-north-1a", public = false }
    "private-2" = { cidr = "10.0.4.0/24", az = "eu-north-1b", public = false }
    "private-3" = { cidr = "10.0.5.0/24", az = "eu-north-1c", public = false }
    "public-3" = { cidr = "10.0.6.0/24", az = "eu-north-1c", public = true }
  }
}

locals {
    name = "ECSv3"
}

locals {
  vpc_endpoints = {
    ecr_api = "ecr.api"
    ecr_dkr = "ecr.dkr"
    logs = "logs"
    sqs = "sqs"
    secretsmanager = "secretsmanager"
    sts = "sts"
    ssmmessages = "ssmmessages"
    ssm = "ssm"
    ec2messages = "ec2messages"
  }
}

locals {
  service_discovery_urls = {
    "dashboard-api" = { name = "dashboard-api", namespace = "ecs.local", port = 8086 }
    "order-service" = { name = "order-service", namespace = "ecs.local", port = 8081 }
    "inventory-service" = { name = "inventory-service", namespace = "ecs.local", port = 8082 }
    "payment-service" = { name = "payment-service", namespace = "ecs.local", port = 8083 }
    "notification-service" = { name = "notification-service", namespace = "ecs.local", port = 8084 }
    "shipping-service" = { name = "shipping-service", namespace = "ecs.local", port = 8085 }
  }
}

locals {
  service_discoveries = {
    dashboard-api = "dashboard-api"
    order-service = "order-service"
    inventory-service = "inventory-service"
    payment-service = "payment-service"
    notification-service = "notification-service"
    shipping-service = "shipping-service"
  }
}