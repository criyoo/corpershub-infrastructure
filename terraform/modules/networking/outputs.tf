output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "api_target_group_arn" {
  description = "api ALB target group ARN."
  value       = try(aws_lb_target_group.api["main"].arn, null)
}

output "alb_dns_name" {
  description = "API ALB DNS name."
  value       = try(aws_lb.this["main"].dns_name, null)
}

output "alb_listener_https" {
  description = "API ALB HTTPS listener."
  value       = try(aws_lb_listener.https["main"], null)
}

output "web_url" {
  description = "Public web URL."
  value       = "https://${var.domain_name}"
}

output "api_url" {
  description = "Public API URL."
  value       = local.api_ingress_enabled ? "https://${var.api_domain_name}" : null
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID."
  value       = aws_cloudfront_distribution.this.id
}


output "cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.this.arn
}

output "cloudfront_distribution" {
  value = aws_cloudfront_distribution.this
}

output "private_subnet_cidrs" {
  value = local.private_subnet_cidrs
}
