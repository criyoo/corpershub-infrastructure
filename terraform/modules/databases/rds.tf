resource "random_password" "master" {
  length           = 16
  special          = true
  override_special = "!#$*?"
}

resource "aws_db_subnet_group" "postgres" {
  name       = "${var.name_prefix}-postgres"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-postgres"
  })
}

resource "aws_db_instance" "postgres" {
  identifier              = "${var.name_prefix}-postgres"
  engine                  = "postgres"
  engine_version          = var.database.engine_version
  instance_class          = var.database.instance_class
  allocated_storage       = var.database.allocated_storage
  max_allocated_storage   = var.database.max_allocated_storage
  storage_type            = "gp3"
  db_name                 = var.database.name
  username                = var.database.username
  password                = random_password.master.result
  backup_retention_period = var.database.backup_retention_period
  multi_az                = var.database.multi_az

  blue_green_update {
    enabled = true
  }

  deletion_protection          = var.database.deletion_protection
  skip_final_snapshot          = var.database.skip_final_snapshot
  final_snapshot_identifier    = var.database.skip_final_snapshot ? null : "${var.name_prefix}-postgres-${formatdate("YYYY-MM-DD", timestamp())}"
  db_subnet_group_name         = aws_db_subnet_group.postgres.name
  vpc_security_group_ids       = [var.postgres_security_group_id]
  publicly_accessible          = false
  auto_minor_version_upgrade   = true
  storage_encrypted            = true
  performance_insights_enabled = var.environment != "prod"
  apply_immediately            = var.environment != "prod"
  copy_tags_to_snapshot        = true

  tags = var.common_tags
}


resource "aws_rds_instance_state" "postgres" {
  identifier = aws_db_instance.postgres.identifier
  state      = var.database.enabled ? "available" : "stopped"
}
