resource "aws_lb" "ecs-v3-alb" {
  name               = "ecs-v3-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.ecs_sg_alb]
  subnets            = [var.public_subnet_ids]

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    prefix  = "ecs-v3-alb"
    enabled = true
  }

  tags = {
    Name = "ecs-v3-alb"
  }
}

resource "aws_lb_target_group" "api-gateway" {
  name     = "api-gateway-target-group"
  target_type = "ip"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
   health_check {
     path = "/healthz"
     interval = 50
     matcher = 200
     timeout = 5
     healthy_threshold = 3
     unhealthy_threshold = 3
  }

  tags = {
    Name = "api-gateway-target-group"
  }
}

resource "aws_lb_target_group" "dashboard-api" {
  name     = "dashboard-api-target-group"
  target_type = "ip"
  port     = 8086
  protocol = "HTTP"
  vpc_id   = var.vpc_id

   health_check {
     path = "/healthz"
     interval = 50
     matcher = 200
     timeout = 5
     healthy_threshold = 3
     unhealthy_threshold = 3
  }

  tags = {
    Name = "dashboard-api-target-group"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ecs-v3-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    # if the wrong path is typed, users are redirected to 404 error page
    fixed_response {
      content_type = "text/plain"
      message_body = "not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "api-gateway" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api-gateway.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

resource "aws_lb_listener_rule" "dashboard-api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dashboard-api.arn
  }

  condition {
    path_pattern {
      values = ["/dashboard/*"]
    }
  }
}

resource "aws_s3_bucket" "alb_logs" {
  bucket = "alb_logs"

  tags = {
    Name = "ecs-v3-alb-logs-bucket"
  }
}

