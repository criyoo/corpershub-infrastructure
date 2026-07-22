output "media_bucket" {
  description = "Media bucket attributes."
  value = {
    id                          = aws_s3_bucket.media.id
    arn                         = aws_s3_bucket.media.arn
    bucket                      = aws_s3_bucket.media.bucket
    bucket_domain_name          = aws_s3_bucket.media.bucket_domain_name
    bucket_regional_domain_name = aws_s3_bucket.media.bucket_regional_domain_name
  }
}

output "media_bucket_arn" {
  description = "Media bucket ARN."
  value       = aws_s3_bucket.media.arn
}

output "media_bucket_domain_name" {
  description = "Media bucket public domain name."
  value       = aws_s3_bucket.media.bucket_regional_domain_name
}

output "web_bucket_id" {
  description = "Web static bucket ID."
  value       = aws_s3_bucket.web.id
}

output "web_bucket_name" {
  description = "Web static bucket name."
  value       = aws_s3_bucket.web.bucket
}

output "web_bucket_arn" {
  description = "Web static bucket ARN."
  value       = aws_s3_bucket.web.arn
}

output "web_bucket_regional_domain_name" {
  description = "Web static bucket regional domain name."
  value       = aws_s3_bucket.web.bucket_regional_domain_name
}

output "api_repository" {
  description = "api ECR repository URL."
  value       = aws_ecr_repository.api
}

output "app_secure_parameter_arns" {
  description = "ARNs of secure application parameters."
  value = {
    for key, parameter in aws_ssm_parameter.app_secure :
    key => parameter.arn
  }
}

output "aws_efs_file_system_id" {
  value = var.tailscale.enabled ? aws_efs_file_system.tailscale_state["main"].id : null
}

output "aws_efs_access_point_id" {
  value = var.tailscale.enabled ? aws_efs_access_point.tailscale_state["main"].id : null
}

output "aws_efs_mount_targets" {
  value = var.tailscale.enabled ? aws_efs_mount_target.tailscale_state : {}
}
