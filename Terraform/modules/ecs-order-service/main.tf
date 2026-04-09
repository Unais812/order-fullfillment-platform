resource "aws_cloudwatch_log_group" "cw_log_group_order_service" {
  name              = var.log_group_name
  retention_in_days = var.log_days
}

resource "aws_ecs_task_definition" "order-service-task" {
  family = local.name
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  execution_role_arn = var.execution_role_arn
  memory = 512
  cpu = 256
  task_role_arn = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = local.name
      image     = var.image
      essential = true

      environment = [
      {
        name  = "SQS_QUEUE_URL"
        value = var.sqs_queue_url
      }
      ]
      
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port
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

      secrets = [
        {
            name = "DATABASE_URL"
            valueFrom = var.database_url_secret_arn
        }
      ]

    },
  ])

  tags = {
    Name = "${local.name}-task"
  }
}

resource "aws_ecs_service" "order-service" {
  name            = "${local.name}-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.order-service-task.arn
  desired_count   = 1
  launch_type = "FARGATE"
  enable_execute_command = true

  network_configuration {
    security_groups = [var.ecs_sg]
    subnets = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = var.service_discovery_arn
  }
}