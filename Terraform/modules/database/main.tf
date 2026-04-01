# This tells RDS which subnets it should go in
resource "aws_db_subnet_group" "rds" {
  name       = "ecs-v3-rds-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "postgres_db" {
  identifier        = "ecs-v3-postgres"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro" 
  allocated_storage = 20
  db_name  = "orders"
  username = "app"
  password = var.db_password  
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [var.rds_sg]
  skip_final_snapshot = true   # allows destroy without taking a snapshot
  deletion_protection = false  # allows tear down at end of project
  publicly_accessible = false  
  multi_az            = false  # saves cost
  storage_encrypted   = true  
}
