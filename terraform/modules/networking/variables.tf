variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "common_tags" {
  description = "Tags applied to networking resources."
  type        = map(string)
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the workload VPC."
  type        = string
}

variable "root_domain_name" {
  description = "Shared public hosted zone name."
  type        = string
}

variable "domain_name" {
  description = "Public web hostname."
  type        = string
}

variable "api_domain_name" {
  description = "Public API hostname."
  type        = string
}

variable "hosted_zone_id" {
  description = "Hosted zone ID for the main and sub domain."
  type        = string
}

variable "iam_web_bucket_access_policy" {
  description = "IAM policy JSON for CloudFront to access the web S3 bucket."
  type        = string
  default     = null
  nullable    = true
}

variable "cloudfront_certificate_arn" {
  description = "Validated ACM certificate ARN for CloudFront."
  type        = string
}

variable "alb_certificate_arn" {
  description = "Validated ACM certificate ARN for the regional API load balancer."
  type        = string
}

variable "web_acl_arn" {
  description = "Optional regional WAF ARN for the API ALB."
  type        = string
  default     = null
  nullable    = true
}

variable "alb_security_group_id" {
  description = "ALB security group ID."
  type        = string
}

variable "web_bucket_id" {
  description = "ID of the private web bucket used as the CloudFront origin."
  type        = string
}

variable "web_bucket_regional_domain_name" {
  description = "Regional domain name of the private web bucket used as the CloudFront origin."
  type        = string
}

variable "enable_waf" {
  description = "Whether to create and attach the regional WAF resources."
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection for ALB and RDS."
  type        = bool
  default     = false
}

variable "api" {
  description = "api ECS sizing and autoscaling settings."
  type = object({
    cpu           = number
    memory        = number
    desired_count = number
    min_count     = number
    max_count     = number
    cpu_target    = number
    enabled       = bool
  })
}
