resource "aws_lb" "ecs-v3-alb" {
  name               = "ecs-v3-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.ecs_sg_alb]
  subnets            = var.public_subnet_ids
  enable_deletion_protection = false

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
     interval = 10
     matcher = 200
     timeout = 5
     healthy_threshold = 2
     unhealthy_threshold = 2
  }
}


resource "aws_lb_target_group" "dashboard-api" {
  name     = "dashboard-api-target-group"
  target_type = "ip"
  port     = 8086
  protocol = "HTTP"
  vpc_id   = var.vpc_id

   health_check {
     path = "/dashboard/healthz"
     interval = 50
     matcher = 200
     timeout = 5
     healthy_threshold = 3
     unhealthy_threshold = 3
  }
}

resource "aws_lb_listener_rule" "dashboard-ui" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 5

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dashboard-api.arn
  }

  condition {
    path_pattern {
      values = [
        "/",
        "/dashboard",
        "/dashboard/*",
        "/static/*",
        "/assets/*"
      ]
    }
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ecs-v3-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "not found"
      status_code  = "404"
    }
  }
}


# Priority 20 — routes all /api/* calls through the api-gateway
resource "aws_lb_listener_rule" "api-gateway" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api-gateway.arn
  }

  condition {
    path_pattern {
      values = [
        "/api/*",
        "/auth/*",
        "/healthz"
        ]
    }
  }
}