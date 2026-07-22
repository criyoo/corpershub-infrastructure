resource "aws_cloudwatch_log_group" "service" {
  for_each = {
    for name, definition in local.service_definitions : name => definition
    if var.api.enabled
  }

  name              = "/ecs/${var.name_prefix}-${each.key}"
  retention_in_days = var.log_retention_in_days

  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "migration" {
  for_each = var.api.enabled ? {
    migration = true
  } : {}

  name              = "/ecs/${var.name_prefix}-${each.key}"
  retention_in_days = var.log_retention_in_days

  tags = var.common_tags
}
