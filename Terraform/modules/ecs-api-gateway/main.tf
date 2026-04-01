resource "aws_cloudwatch_log_group" "cw_log_group" {
  name              = var.log_group_name
  retention_in_days = var.log_days
}

resource "aws_ecs_task_definition" "api-gateway-task" {
  family = local.name
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  execution_role_arn = var.execution_role_arn
  memory = 512
  cpu = 256

  container_definitions = jsonencode([
    {
      name      = local.name
      image     = var.image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"       = aws_cloudwatch_log_group.cw_log_group.name
          awslogs-region        = var.region
          awslogs-stream-prefix = var.logstream_prefix

        }
       }

      secrets = [
        {
            name = "JWT_SECRET"
            valueFrom = var.jwt_secret_arn
        }
      ]
    },
  ])

  tags = {
    Name = "${local.name}-task"
  }
}

resource "aws_ecs_service" "api-gateway-service" {
  name            = "${local.name}-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.api-gateway-task.arn
  desired_count   = 1
  launch_type = "FARGATE"

  network_configuration {
    security_groups = [var.ecs_sg]
    subnets = var.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.api_gateway_target_group
    container_name   = local.name
    container_port   = var.container_port
  }
}