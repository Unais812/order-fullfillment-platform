resource "aws_cloudwatch_log_group" "cw_log_group_api" {
  name              = var.log_group_name_api
  retention_in_days = var.log_days
}

resource "aws_ecs_task_definition" "api-gateway-task" {
  family = local.name_api
  requires_compatibilities = ["FARGATE"]
  network_mode = var.network_mode
  execution_role_arn = var.execution_role_arn
  memory = var.memory
  cpu = var.cpu
  task_role_arn = var.task_role_arn_api

  container_definitions = jsonencode([
    {
      health_check = {
        path = "/healthz"
        interval = 5
        timeout = 5
      }

      name      = local.name_api
      image     = var.image_api
      essential = true

      portMappings = [
        {
          containerPort = var.container_port_api
          hostPort      = var.host_port_api
          protocol      = "tcp"
        }
      ]

      environment = [
      {
        name  = "REDIS_URL"
        value = var.elasticache_url
      },
      {
        name  = "ORDER_SERVICE_URL"
        value = var.order_service_url
      },
      {
        name  = "INVENTORY_SERVICE_URL"
        value = var.inventory_service_url
      },
      {
        name  = "PAYMENT_SERVICE_URL"
        value = var.payment_service_url
      },
      {
        name  = "NOTIFICATION_SERVICE_URL"
        value = var.notification_service_url
      },
      {
        name  = "SHIPPING_SERVICE_URL"
        value = var.shipping_service_url
      },
      {
        name  = "DASHBOARD_SERVICE_URL"
        value = var.dashboard_service_url
      }
    ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"       = aws_cloudwatch_log_group.cw_log_group_api.name
          awslogs-region        = var.region
          awslogs-stream-prefix = var.logstream_prefix

        }
       }


    },
  ])

  tags = {
    Name = "${local.name_api}-task"
  }
}

resource "aws_ecs_service" "api-gateway-service" {
  name            = "${local.name_api}-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.api-gateway-task.arn
  desired_count   = var.desired_count
  launch_type = var.launch_type
  enable_execute_command = true

  # CI/CD manages the task definition after initial creation.
  # Without this, terraform apply reverts every deployment CI/CD has done.

  network_configuration {
    security_groups = [var.ecs_sg]
    subnets = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = var.service_discovery_arn_api
  }

  load_balancer {
    target_group_arn = var.api_gateway_target_group
    container_name   = local.name_api
    container_port   = var.container_port_api
  }
}

///// Dashboard-Service /////

resource "aws_cloudwatch_log_group" "cw_log_group_dashboard_api" {
  name              = var.log_group_name_dashboard
  retention_in_days = var.log_days
}

resource "aws_ecs_task_definition" "dashboard-api-task" {
  family = local.name_dashboard
  requires_compatibilities = ["FARGATE"]
  network_mode = var.network_mode
  execution_role_arn = var.execution_role_arn
  memory = var.memory
  cpu = var.cpu
  task_role_arn = var.task_role_arn_dashboard

  container_definitions = jsonencode([
    {
      name      = local.name_dashboard
      image     = var.image_dashboard
      essential = true
      environment = [
        {
            name = "DATABASE_URL"
            value = "postgres://app:${var.db_password}@${var.rds_endpoint}:5432/orders"
        }
      ]
    
      portMappings = [
        {
          containerPort = var.container_port_dashboard
          hostPort      = var.host_port_dashboard
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"       = aws_cloudwatch_log_group.cw_log_group_dashboard_api.name
          awslogs-region        = var.region
          awslogs-stream-prefix = var.logstream_prefix

        }
       }
    },
  ])

  tags = {
    Name = "${local.name_dashboard}-task"
  }
}

resource "aws_ecs_service" "dashboard-api-service" {
  name            = "${local.name_dashboard}-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.dashboard-api-task.arn
  desired_count   = var.desired_count
  launch_type = var.launch_type
  enable_execute_command = true

  network_configuration {
    security_groups = [var.ecs_sg]
    subnets = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = var.service_discovery_arn_dashboard
  }


  load_balancer {
    target_group_arn = var.dashboard_api_target_group
    container_name   = local.name_dashboard
    container_port   = var.container_port_dashboard
  }
}

///// Inventory-service /////

resource "aws_cloudwatch_log_group" "cw_log_group_inventory_service" {
  name              = var.log_group_name_inventory
  retention_in_days = var.log_days
}

resource "aws_ecs_task_definition" "inventory-service-task" {
  family = local.name_inventory
  requires_compatibilities = ["FARGATE"]
  network_mode = var.network_mode
  execution_role_arn = var.execution_role_arn
  memory = var.memory
  cpu = var.cpu
  task_role_arn = var.task_role_arn_inventory

  container_definitions = jsonencode([
    {
      name      = local.name_inventory
      image     = var.image_inventory
      essential = true

      environment = [
        {
            name = "DATABASE_URL"
            value = "postgres://app:${var.db_password}@${var.rds_endpoint}:5432/orders"
        }
      ]
      
      portMappings = [
        {
          containerPort = var.container_port_inventory
          hostPort      = var.host_port_inventory
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"       = aws_cloudwatch_log_group.cw_log_group_inventory_service.name
          awslogs-region        = var.region
          awslogs-stream-prefix = var.logstream_prefix

        }
       }
    },
  ])

  tags = {
    Name = "${local.name_inventory}-task"
  }
}

resource "aws_ecs_service" "inventory-service" {
  name            = "${local.name_inventory}-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.inventory-service-task.arn
  desired_count   = var.desired_count
  launch_type = var.launch_type

  network_configuration {
    security_groups = [var.ecs_sg]
    subnets = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = var.service_discovery_arn_inventory
  }
}

///// Notification-service /////

resource "aws_cloudwatch_log_group" "cw_log_group_notification_service" {
  name              = var.log_group_name_notification
  retention_in_days = var.log_days
}

resource "aws_ecs_task_definition" "notification-service-task" {
  family = local.name_notification
  requires_compatibilities = ["FARGATE"]
  network_mode = var.network_mode
  execution_role_arn = var.execution_role_arn
  memory = var.memory
  cpu = var.cpu
  task_role_arn = var.task_role_arn_notification
  container_definitions = jsonencode([
    {
      name      = local.name_notification
      image     = var.image_notification
      essential = true

      environment = [
        {
            name = "DATABASE_URL"
            value = "postgres://app:${var.db_password}@${var.rds_endpoint}:5432/orders"
        }
      ]

      portMappings = [
        {
          containerPort = var.container_port_notification
          hostPort      = var.host_port_notification
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"       = aws_cloudwatch_log_group.cw_log_group_notification_service.name
          awslogs-region        = var.region
          awslogs-stream-prefix = var.logstream_prefix

        }
       }
    },
  ])

  tags = {
    Name = "${local.name_notification}-task"
  }
}

resource "aws_ecs_service" "notification-service" {
  name            = "${local.name_notification}-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.notification-service-task.arn
  desired_count   = var.desired_count
  launch_type = var.launch_type

  network_configuration {
    security_groups = [var.ecs_sg]
    subnets = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = var.service_discovery_arn_notification
  }
}

///// Order-service /////

resource "aws_cloudwatch_log_group" "cw_log_group_order_service" {
  name              = var.log_group_name_order
  retention_in_days = var.log_days
}

resource "aws_ecs_task_definition" "order-service-task" {
  family = local.name_order
  requires_compatibilities = ["FARGATE"]
  network_mode = var.network_mode
  execution_role_arn = var.execution_role_arn
  memory = var.memory
  cpu = var.cpu
  task_role_arn = var.task_role_arn_order

  container_definitions = jsonencode([
    {
      name      = local.name_order
      image     = var.image_order
      essential = true    

      environment = [
      {
        name  = "SQS_QUEUE_URL"
        value = var.sqs_queue_url
      },
      {
        name = "DATABASE_URL"
        value = "postgres://app:${var.db_password}@${var.rds_endpoint}:5432/orders"
      }
      ]
      
      portMappings = [
        {
          containerPort = var.container_port_order
          hostPort      = var.host_port_order
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"       = aws_cloudwatch_log_group.cw_log_group_order_service.name
          awslogs-region        = var.region
          awslogs-stream-prefix = var.logstream_prefix

        }
       }
    },
  ])

  tags = {
    Name = "${local.name_order}-task"
  }
}

resource "aws_ecs_service" "order-service" {
  name            = "${local.name_order}-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.order-service-task.arn
  desired_count   = var.desired_count
  launch_type = var.launch_type
  enable_execute_command = true


  network_configuration {
    security_groups = [var.ecs_sg]
    subnets = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = var.service_discovery_arn_order
  }
}

///// Payment-service /////

resource "aws_cloudwatch_log_group" "cw_log_group_payment_service" {
  name              = var.log_group_name_payment
  retention_in_days = var.log_days
}

resource "aws_ecs_task_definition" "payment-service-task" {
  family = local.name_payment
  requires_compatibilities = ["FARGATE"]
  network_mode = var.network_mode
  execution_role_arn = var.execution_role_arn
  memory = var.memory
  cpu = var.cpu
  task_role_arn = var.task_role_arn_payment

  container_definitions = jsonencode([
    {
      name      = local.name_payment
      image     = var.image_payment
      essential = true

      environment = [
      {
        name  = "SQS_QUEUE_URL"
        value = var.sqs_queue_url
      },
      {
        name = "DATABASE_URL"
        value = "postgres://app:${var.db_password}@${var.rds_endpoint}:5432/orders"
      }
      ]
      
      
      portMappings = [
        {
          containerPort = var.container_port_payment
          hostPort      = var.host_port_payment
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"       = aws_cloudwatch_log_group.cw_log_group_payment_service.name
          awslogs-region        = var.region
          awslogs-stream-prefix = var.logstream_prefix

        }
       }
    },
  ])

  tags = {
    Name = "${local.name_payment}-task"
  }
}

resource "aws_ecs_service" "payment-service" {
  name            = "${local.name_payment}-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.payment-service-task.arn
  desired_count   = var.desired_count
  launch_type = var.launch_type

  network_configuration {
    security_groups = [var.ecs_sg]
    subnets = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = var.service_discovery_arn_payment
  }
}

///// Scheduler-service /////

resource "aws_cloudwatch_log_group" "cw_log_group_scheduler" {
  name              = var.log_group_name_scheduler
  retention_in_days = var.log_days
}


resource "aws_ecs_task_definition" "scheduler-task" {
  family = local.name_scheduler
  requires_compatibilities = ["FARGATE"]
  network_mode = var.network_mode
  execution_role_arn = var.execution_role_arn
  memory = var.memory
  cpu = var.cpu
  task_role_arn = var.task_role_arn_scheduler

  container_definitions = jsonencode([
    {
      name      = local.name_scheduler
      image     = var.image_scheduler
      essential = true

      environment = [
        {
          name = "DATABASE_URL"
          value = "postgres://app:${var.db_password}@${var.rds_endpoint}:5432/orders"
        }
      ]      
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"       = aws_cloudwatch_log_group.cw_log_group_scheduler.name
          awslogs-region        = var.region
          awslogs-stream-prefix = var.logstream_prefix

        }
       }
    },
  ])

  tags = {
    Name = "${local.name_scheduler}-task"
  }
}

resource "aws_ecs_service" "scheduler-service" {
  name            = "${local.name_scheduler}"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.scheduler-task.arn
  desired_count   = var.desired_count
  launch_type = var.launch_type

  network_configuration {
    security_groups = [var.ecs_sg]
    subnets = var.private_subnet_ids
    assign_public_ip = false
  }
}

///// Shipping-service /////

resource "aws_cloudwatch_log_group" "cw_log_group_shipping_service" {
  name              = var.log_group_name_shipping
  retention_in_days = var.log_days
}

resource "aws_ecs_task_definition" "shipping-service-task" {
  family = local.name_shipping
  requires_compatibilities = ["FARGATE"]
  network_mode = var.network_mode
  execution_role_arn = var.execution_role_arn
  memory = var.memory
  cpu = var.cpu
  task_role_arn = var.task_role_arn_shipping

  container_definitions = jsonencode([
    {
      name      = local.name_shipping
      image     = var.image_shipping
      essential = true

      environment = [
      {
        name  = "SQS_QUEUE_URL"
        value = var.sqs_queue_url
      },
      {
        name = "DATABASE_URL"
        value = "postgres://app:${var.db_password}@${var.rds_endpoint}:5432/orders"
      }
      ]
  
      portMappings = [
        {
          containerPort = var.container_port_shipping
          hostPort      = var.host_port_shipping
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"       = aws_cloudwatch_log_group.cw_log_group_shipping_service.name
          awslogs-region        = var.region
          awslogs-stream-prefix = var.logstream_prefix

        }
       }
    },
  ])

  tags = {
    Name = "${local.name_shipping}-task"
  }
}

resource "aws_ecs_service" "shipping-service" {
  name            = "${local.name_shipping}-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.shipping-service-task.arn
  desired_count   = var.desired_count
  launch_type = var.launch_type

  network_configuration {
    security_groups = [var.ecs_sg]
    subnets = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = var.service_discovery_arn_shipping
  }
}

///// Worker-service /////

resource "aws_cloudwatch_log_group" "cw_log_group_worker" {
  name              = var.log_group_name_worker
  retention_in_days = var.log_days
}

resource "aws_ecs_task_definition" "worker-task" {
  family = local.name_worker
  requires_compatibilities = ["FARGATE"]
  network_mode = var.network_mode
  execution_role_arn = var.execution_role_arn
  memory = var.memory
  cpu = var.cpu
  task_role_arn = var.task_role_arn_worker

  container_definitions = jsonencode([
    {
      name      = local.name_worker
      image     = var.image_worker
      essential = true
       
     environment = [
      {
        name  = "SQS_QUEUE_URL"
        value = var.sqs_queue_url
      },
      {
        name  = "ORDER_SERVICE_URL"
        value = var.order_service_url
      },
      {
        name  = "INVENTORY_SERVICE_URL"
        value = var.inventory_service_url
      },
      {
        name  = "PAYMENT_SERVICE_URL"
        value = var.payment_service_url
      },
      {
        name  = "NOTIFICATION_SERVICE_URL"
        value = var.notification_service_url
      },
      {
        name  = "SHIPPING_SERVICE_URL"
        value = var.shipping_service_url
      }
    ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"       = aws_cloudwatch_log_group.cw_log_group_worker.name
          awslogs-region        = var.region
          awslogs-stream-prefix = var.logstream_prefix

        }
       }


    },
  ])

  tags = {
    Name = "${local.name_worker}-task"
  }
}

resource "aws_ecs_service" "worker-service" {
  name            = "${local.name_worker}-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.worker-task.arn
  desired_count   = var.desired_count
  launch_type = var.launch_type

  network_configuration {
    security_groups = [var.ecs_sg]
    subnets = var.private_subnet_ids
    assign_public_ip = false
  }
}