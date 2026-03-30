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