# resource "aws_secretsmanager_secret" "db_password" {
#   name = "db_password"

#   lifecycle {
#     prevent_destroy = true
#   }
# }

# resource "aws_secretsmanager_secret_version" "db" {
#   secret_id     = aws_secretsmanager_secret.db_password.id
#   secret_string = var.db_password
# }

resource "aws_secretsmanager_secret" "database_url" {
  name = "database_url"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "database_url" {
  secret_id     = aws_secretsmanager_secret.database_url.id
  secret_string = "postgres://app:${var.db_password}@${var.rds_endpoint}:5432/orders"
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name = "jwt_secret"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id     = aws_secretsmanager_secret.jwt_secret.id
  secret_string = var.jwt_secret
}