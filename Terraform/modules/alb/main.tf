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

  tags = {
    Name = "api-gateway-target-group"
  }
}



resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ecs-v3-alb.arn
  port              = 80
  protocol          = "HTTP"

 default_action {
  type             = "forward"
  target_group_arn = aws_lb_target_group.api-gateway.arn
}
}
