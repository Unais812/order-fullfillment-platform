variable "private_subnet_ids" {
  description = "ids for private subnets"
  type = list(string)
}

variable "rds_sg" {
  description = "sg for the rds instance"
  type = string
}

variable "db_password" {
  description = "db password"
  type = string
}