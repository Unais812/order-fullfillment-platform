resource "aws_secretsmanager_secret" "db" {
  name = "ecs-v3/db/password"
}

resource "aws_secretsmanager_secret" "jwt" {
  name = "ecs-v3/jwt/secret"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = var.db_password
}

resource "aws_secretsmanager_secret_version" "jwt" {
  secret_id     = aws_secretsmanager_secret.jwt.id
  secret_string = var.jwt_secret
}