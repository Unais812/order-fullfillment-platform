variable "db_password" {
  description = "password for db"
  type = string
  sensitive = true
}

variable "jwt_secret" {
  description = "jwt secret"
  type = string
  sensitive = true
}

