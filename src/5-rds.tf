resource "random_string" "password" {
  #  for_each = toset(var.K8S_NAMESPACES)

  for_each = toset(var.K8S_NAMESPACES)


  length           = 16
  upper            = true
  lower            = true
  numeric          = true
  special          = false
  /* variables that when changed force a resource regeneration */
  keepers          = {}
  override_special = "@"

  lifecycle {
    ignore_changes = [
      length,
      upper,
      lower,
      numeric,
      special,
    ]
  }
}

resource "random_string" "username" {
  for_each         = toset(var.K8S_NAMESPACES)
  length           = 16
  upper            = true
  lower            = true
  numeric          = true
  special          = false
  /* variables that when changed force a resource regeneration */
  keepers          = {}
  override_special = ""

  lifecycle {
    ignore_changes = [
      length,
      upper,
      lower,
      numeric,
      special,
    ]
  }
}
resource "aws_ssm_parameter" "password" {
  for_each  = toset(var.K8S_NAMESPACES)
  name      = "tbc.rds.${each.value}.password"
  type      = "SecureString"
  value     = random_string.password[each.value].result
  key_id    = aws_kms_key.main.id
  overwrite = true
}

resource "aws_ssm_parameter" "username" {
  for_each  = toset(var.K8S_NAMESPACES)
  name      = "tbc.rds.${each.value}.username"
  type      = "String"
  value     = random_string.username[each.value].result
  overwrite = true
}


resource "aws_db_subnet_group" "rds" {
  name       = "tbc.rds.subnet-group.${local.project.slug}"
  subnet_ids = aws_subnet.privates.*.id
}

resource "aws_db_instance" "default" {
  for_each = {for rds_config in var.RDS_DATABASES : rds_config.identifier => rds_config}

  allocated_storage     = each.value.allocated_storage
  max_allocated_storage = each.value.max_allocated_storage
  identifier            = each.value.identifier
  instance_class        = each.value.instance_class
  db_name               = each.value.db_name
  multi_az              = each.value.multi_az
  engine                = "postgres"
  engine_version        = "14.4"

  username                              = aws_ssm_parameter.username[each.value.namespace].value
  password                              = aws_ssm_parameter.password[each.value.namespace].value
  backup_retention_period               = 7
  performance_insights_retention_period = 7
  #  monitoring_interval                   = 60
  kms_key_id                            = aws_kms_key.main.arn
  performance_insights_kms_key_id       = aws_kms_key.main.arn
  iam_database_authentication_enabled   = true
  performance_insights_enabled          = true
  storage_encrypted                     = true
  skip_final_snapshot                   = true
  publicly_accessible                   = false
  vpc_security_group_ids                = [aws_security_group.rds.id]
  db_subnet_group_name                  = aws_db_subnet_group.rds.name

  parameter_group_name = "default.postgres14"

  depends_on = [
    aws_vpc.main,
    aws_subnet.privates,
    aws_subnet.public,
    aws_db_subnet_group.rds
  ]
}