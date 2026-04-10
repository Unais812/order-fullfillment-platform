resource "aws_iam_role" "ecs_execution_iam_role" {
  name = "ecs_execution_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_policy_attachment" {
  role       = aws_iam_role.ecs_execution_iam_role.name
  policy_arn = var.secrets_policy_arn
}

resource "aws_iam_role_policy_attachment" "task_execution_policy_attachment" {
  role = aws_iam_role.ecs_execution_iam_role.name
  policy_arn = var.task_execution_policy_arn
}

# trust policy
data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "order_service_task_role" {
  name               = "ecs-v3-order-service-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = {
    Name = "ecs-v3-order-service-task-role"
  }
}

resource "aws_iam_role_policy" "order_service_sqs_policy" {
  name = "ecs-v3-order-service-sqs-policy"
  role = aws_iam_role.order_service_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "SQSSendAccess"
        Effect = "Allow"

        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]

        Resource = var.sqs_queue_arn
      },
      {
        Sid = "ECSServiceDiscovery"
        Effect = "Allow"

        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:ListServices",
          "ecs:DescribeTaskDefinition"
        ]

        Resource = "*"
      },
      {
        Sid = "RDSDescribeAccess"
        Effect = "Allow"

        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:ListTagsForResource"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "payment_service_task_role" {
  name               = "ecs-v3-payment-service-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = {
    Name = "ecs-v3-payment-service-task-role"
  }
}

resource "aws_iam_role_policy" "payment_service_sqs_policy" {
  name = "ecs-v3-payment-service-sqs-policy"
  role = aws_iam_role.payment_service_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "SQSSendAccess"
        Effect = "Allow"

        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]

        Resource = var.sqs_queue_arn
      },
      {
        Sid = "ECSServiceDiscovery"
        Effect = "Allow"

        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:ListServices",
          "ecs:DescribeTaskDefinition"
        ]

        Resource = "*"
      },
      {
        Sid = "RDSDescribeAccess"
        Effect = "Allow"

        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:ListTagsForResource"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "shipping_service_task_role" {
  name               = "ecs-v3-shipping-service-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = {
    Name = "ecs-v3-shipping-service-task-role"
  }
}

resource "aws_iam_role_policy" "shipping_service_policy" {
  name = "ecs-v3-shipping-service-sqs-policy"
  role = aws_iam_role.shipping_service_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "SQSSendAccess"
        Effect = "Allow"

        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]

        Resource = var.sqs_queue_arn
      },
      {
        Sid = "ECSServiceDiscovery"
        Effect = "Allow"

        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:ListServices",
          "ecs:DescribeTaskDefinition"
        ]

        Resource = "*"
      },
      {
        Sid = "RDSDescribeAccess"
        Effect = "Allow"

        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:ListTagsForResource"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "dashboard_api_task_role" {
  name               = "ecs-v3-dashboard-api-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = {
    Name = "ecs-v3-dashboard-api-task-role"
  }
}

resource "aws_iam_role_policy" "dashboard_api_policy" {
  name = "ecs-v3-dashboard-api-policy"
  role = aws_iam_role.dashboard_api_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "SQSSendAccess"
        Effect = "Allow"

        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]

        Resource = var.sqs_queue_arn
      },
      {
        Sid = "ECSServiceDiscovery"
        Effect = "Allow"

        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:ListServices",
          "ecs:DescribeTaskDefinition"
        ]

        Resource = "*"
      },
      {
        Sid = "RDSDescribeAccess"
        Effect = "Allow"

        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:ListTagsForResource"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "api_gateway_task_role" {
  name               = "ecs-v3-api-gateway-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = {
    Name = "ecs-v3-api-gateway-task-role"
  }
}

resource "aws_iam_role_policy" "api_gateway_policy" {
  name = "ecs-v3-api-gateway-task-policy"
  role = aws_iam_role.api_gateway_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECSServiceDiscovery"
        Effect = "Allow"

        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:ListServices",
          "ecs:DescribeTaskDefinition"
        ]

        Resource = "*"
      },
      {
        Sid    = "ElastiCacheAccess"
        Effect = "Allow"

        Action = [
          "elasticache:DescribeCacheClusters",
          "elasticache:DescribeReplicationGroups",
          "elasticache:ListTagsForResource"
        ]

        Resource = "*"
      },

      {
        "Effect": "Allow",
        "Action": [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role" "notification_service_task_role" {
  name               = "ecs-v3-notification-service-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = {
    Name = "ecs-v3-notification-service-task-role"
  }
}

resource "aws_iam_role_policy" "notification_service_policy" {
  name = "ecs-v3-notification-service-policy"
  role = aws_iam_role.notification_service_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "SQSSendAccess"
        Effect = "Allow"

        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]

        Resource = var.sqs_queue_arn
      },
      {
        Sid = "ECSServiceDiscovery"
        Effect = "Allow"

        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:ListServices",
          "ecs:DescribeTaskDefinition"
        ]

        Resource = "*"
      },
      {
        Sid = "RDSDescribeAccess"
        Effect = "Allow"

        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:ListTagsForResource"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "scheduler_service_task_role" {
  name               = "ecs-v3-scheduler-service-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = {
    Name = "ecs-v3-scheduler-service-task-role"
  }
}

resource "aws_iam_role_policy" "scheduler_service_policy" {
  name = "ecs-v3-scheduler-service-policy"
  role = aws_iam_role.scheduler_service_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "SQSSendAccess"
        Effect = "Allow"

        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]

        Resource = var.sqs_queue_arn
      },
      {
        Sid = "ECSServiceDiscovery"
        Effect = "Allow"

        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:ListServices",
          "ecs:DescribeTaskDefinition"
        ]

        Resource = "*"
      },
      {
        Sid = "RDSDescribeAccess"
        Effect = "Allow"

        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:ListTagsForResource"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "worker_service_task_role" {
  name               = "ecs-v3-worker-service-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = {
    Name = "ecs-v3-worker-service-task-role"
  }
}

resource "aws_iam_role_policy" "worker_service_policy" {
  name = "ecs-v3-worker-service-policy"
  role = aws_iam_role.worker_service_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "SQSSendAccess"
        Effect = "Allow"

        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]

        Resource = var.sqs_queue_arn
      },
      {
        Sid = "ECSServiceDiscovery"
        Effect = "Allow"

        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:ListServices",
          "ecs:DescribeTaskDefinition"
        ]

        Resource = "*"
      },
      {
        Sid = "RDSDescribeAccess"
        Effect = "Allow"

        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:ListTagsForResource"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "inventory_service_task_role" {
  name               = "ecs-v3-inventory-service-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = {
    Name = "ecs-v3-inventory-service-task-role"
  }
}

resource "aws_iam_role_policy" "inventory_service_policy" {
  name = "ecs-v3-inventory-service-policy"
  role = aws_iam_role.inventory_service_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "SQSSendAccess"
        Effect = "Allow"

        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]

        Resource = var.sqs_queue_arn
      },
      {
        Sid = "ECSServiceDiscovery"
        Effect = "Allow"

        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:ListServices",
          "ecs:DescribeTaskDefinition"
        ]

        Resource = "*"
      },
      {
        Sid = "RDSDescribeAccess"
        Effect = "Allow"

        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:ListTagsForResource"
        ]

        Resource = "*"
      }
    ]
  })
}