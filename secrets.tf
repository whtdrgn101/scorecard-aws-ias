resource "random_password" "sc_random_db_pass" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "sc_db_password" {
  name = "scorecard-db-password"
}

resource "aws_secretsmanager_secret_version" "sc_db_password" {
  secret_id = aws_secretsmanager_secret.sc_db_password.id
  secret_string = random_password.sc_random_db_pass.result
}