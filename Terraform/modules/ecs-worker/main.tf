resource "aws_cloudwatch_log_group" "cw_log_group_worker" {
  name              = var.log_group_name
  retention_in_days = var.log_days
}

resource "aws_ecs_task_definition" "worker-task" {
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
    Name = "${local.name}-task"
  }
}

resource "aws_ecs_service" "worker-service" {
  name            = "${local.name}-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.worker-task.arn
  desired_count   = 1
  launch_type = "FARGATE"

  lifecycle {
    ignore_changes = [task_definition]
  }

  network_configuration {
    security_groups = [var.ecs_sg]
    subnets = var.private_subnet_ids
    assign_public_ip = false
  }
}