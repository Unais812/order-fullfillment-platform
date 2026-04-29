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

resource "aws_vpc_security_group_egress_rule" "ecs_to_vpce" {
  security_group_id = aws_security_group.vpc_endpoint_sg.id
  ip_protocol = "-1"
  referenced_security_group_id = aws_security_group.ecs_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "ecs-sg-ingress-all-load-balancer" {
  security_group_id = aws_security_group.ecs_sg.id
  referenced_security_group_id = aws_security_group.ecs_sg_alb.id
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "ecs-sg-ingress-all" {
  security_group_id = aws_security_group.ecs_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ecs" {
  security_group_id = aws_security_group.ecs_sg.id
  cidr_ipv4         = var.allow_all_traffic_cidr
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# allow any ECS task to talk to any other ECS task on any port
resource "aws_vpc_security_group_ingress_rule" "ecs-sg-internal" {
  security_group_id            = aws_security_group.ecs_sg.id
  referenced_security_group_id = aws_security_group.ecs_sg.id
  from_port                    = 0
  to_port                      = 65535
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "vpc_endpoint_sg" {
  name   = "vpc-endpoint-sg"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "vpc-endpoint-sg-ingress" {
  security_group_id = aws_security_group.vpc_endpoint_sg.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "vpc-endpoint-sg-ingress-referenced" {
  security_group_id = aws_security_group.vpc_endpoint_sg.id
  ip_protocol = "-1"
  referenced_security_group_id = aws_security_group.ecs_sg.id
}


resource "aws_vpc_security_group_egress_rule" "allow_all_egress_traffic_rds" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4         = var.allow_all_traffic_cidr
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "rds_sg" {
  name   = "rds_sg"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "rds-sg-ingress" {
  security_group_id = aws_security_group.rds_sg.id
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
  referenced_security_group_id = aws_security_group.ecs_sg.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_traffic" {
  security_group_id = aws_security_group.vpc_endpoint_sg.id
  cidr_ipv4         = var.allow_all_traffic_cidr
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "elasticache_sg" {
  name = "elasticache_sg"
  vpc_id = var.vpc_id
}


resource "aws_vpc_security_group_ingress_rule" "elasticache-sg-ingress" {
  security_group_id = aws_security_group.elasticache_sg.id
  from_port         = 6379
  ip_protocol       = "tcp"
  to_port           = 6379
  referenced_security_group_id = aws_security_group.ecs_sg.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_traffic_elasticache" {
  security_group_id = aws_security_group.elasticache_sg.id
  cidr_ipv4         = var.allow_all_traffic_cidr
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# resource "aws_vpc_security_group_ingress_rule" "ecs-sg-ingress-elasticache" {
#   security_group_id = aws_security_group.ecs_sg.id
#   referenced_security_group_id = aws_security_group.elasticache_sg.id
#   from_port = 6379
#   ip_protocol = "tcp"
#   to_port = 6379
# }

# resource "aws_vpc_security_group_ingress_rule" "ecs-sg-ingress" {
#   security_group_id = aws_security_group.ecs_sg.id
#   referenced_security_group_id = aws_security_group.ecs_sg_alb.id
#   from_port         = 8080
#   ip_protocol       = "tcp"
#   to_port           = 8080
# }

# resource "aws_vpc_security_group_ingress_rule" "ecs-sg-ingress-8086" {
#   security_group_id = aws_security_group.ecs_sg.id
#   referenced_security_group_id = aws_security_group.ecs_sg_alb.id
#   from_port         = 8086
#   ip_protocol       = "tcp"
#   to_port           = 8086
# }