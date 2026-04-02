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

resource "aws_iam_role" "worker_task_role" {
  name               = "ecs-v3-worker-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = {
    Name = "ecs-v3-worker-task-role"
  }
}

resource "aws_iam_role_policy" "worker_sqs_policy" {
  name = "ecs-v3-worker-sqs-policy"
  role = aws_iam_role.worker_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = var.sqs_queue_arn
      }
    ]
  })
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
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = var.sqs_queue_arn
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
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = var.sqs_queue_arn
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

resource "aws_iam_role_policy" "shipping_service_sqs_policy" {
  name = "ecs-v3-shipping-service-sqs-policy"
  role = aws_iam_role.shipping_service_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = var.sqs_queue_arn
      }
    ]
  })
}
