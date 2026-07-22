resource "aws_ssm_parameter" "app_secure" {
  for_each = local.api_secure_parameter_keys

  name  = "/${var.project_name}/${var.environment}/secret/${each.key}"
  type  = "SecureString"
  value = var.api_secure_parameters[each.key]

  tags = var.common_tags
}
