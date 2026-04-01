output "ecs_sg" {
  value = aws_security_group.ecs_sg.id
}

output "ecs_sg_alb" {
  value = aws_security_group.ecs_sg_alb.id
}

output "vpc_endpoint_sg" {
  value = aws_security_group.vpc_endpoint_sg.id
}

output "rds_sg" {
  value = aws_security_group.rds_sg.id
}