resource "aws_security_group" "ecs_sg_alb" {
  name        = "ecs_sg_slb"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ecs_sg_alb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.ecs_sg_alb.id
  cidr_ipv4         = var.allow_all_traffic_cidr
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.ecs_sg_alb.id
  cidr_ipv4         = var.allow_all_traffic_cidr
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.ecs_sg_alb.id
  cidr_ipv4         = var.allow_all_traffic_cidr
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-v3-sg"
  description = "Allow traffic from container port"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ecs-v3-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs-sg-ingress" {
  security_group_id = aws_security_group.ecs_sg.id
  referenced_security_group_id = aws_security_group.ecs_sg_alb.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ecs" {
  security_group_id = aws_security_group.ecs_sg.id
  cidr_ipv4         = var.allow_all_traffic_cidr
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "vpc_endpoint_sg" {
  name   = "vpc-endpoint-sg"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "vpc-endpoint-sg-ingress" {
  security_group_id = aws_security_group.vpc_endpoint_sg.id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  referenced_security_group_id = aws_security_group.ecs_sg.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_traffic_ecs" {
  security_group_id = aws_security_group.vpc_endpoint_sg.id
  cidr_ipv4         = var.allow_all_traffic_cidr
  ip_protocol       = "-1" # semantically equivalent to all ports
}