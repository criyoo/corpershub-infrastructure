terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.root, aws.acm]
    }
  }
}

variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "common_tags" {
  description = "Tags applied to security resources."
  type        = map(string)
}

variable "enable_waf" {
  description = "Whether to create a regional WAF for the public API ALB."
  type        = bool
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
  description = "Hosted zone ID for the root domain."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the security groups."
  type        = string
}

variable "web_bucket_arn" {
  description = "Web bucket ARN."
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN."
  type        = string
  default     = null
  nullable    = true
}
