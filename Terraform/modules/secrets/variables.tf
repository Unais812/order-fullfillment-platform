variable "db_password" {
  description = "password for db"
  type = string
  sensitive = true
}

variable "rds_endpoint" {
  description = "rds endpoint"
  type = string
}

variable "jwt_secret" {
  description = "jwt secret"
  type = string
}