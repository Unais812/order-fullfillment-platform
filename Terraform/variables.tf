variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}

variable "database_url_secret_arn" {
  description = "url for the database"
  type = string
  sensitive = true
}

variable "jwt_secret" {
  description = "jwt_secret"
  type = string
  sensitive = true
}