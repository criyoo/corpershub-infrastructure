# Security outputs are defined alongside the resources that produce them.
output "app_security_group_id" {
  description = "Application task security group ID."
  value       = aws_security_group.api.id
}

output "postgres_security_group_id" {
  description = "PostgreSQL security group ID."
  value       = aws_security_group.postgres.id
}

output "valkey_security_group_id" {
  description = "Valkey security group ID."
  value       = aws_security_group.valkey.id
}

output "alb_security_group_id" {
  description = "ALB security group ID."
  value       = aws_security_group.alb.id
}

output "cloudfront_certificate_arn" {
  description = "Validated ACM certificate ARN for the web CloudFront distribution in us-east-1."
  value       = aws_acm_certificate_validation.cloudfront.certificate_arn
}

output "alb_certificate_arn" {
  description = "Validated ACM certificate ARN for the regional API ALB."
  value       = aws_acm_certificate_validation.alb.certificate_arn
}

output "iam_web_bucket_access_policy" {
  description = "IAM policy JSON for CloudFront to access the web S3 bucket."
  value       = data.aws_iam_policy_document.web_bucket_access.json
}
