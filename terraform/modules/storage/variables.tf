variable "project_name" {
  description = "Project identifier used in parameter paths."
  type        = string
}

variable "account_id" {
  description = "AWS account id"
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "common_tags" {
  description = "Tags applied to storage resources."
  type        = map(string)
}

variable "api_string_parameters" {
  description = "Non-sensitive application configuration."
  type        = map(string)
  default     = {}
}

variable "api_secure_parameters" {
  description = "Sensitive application configuration."
  type        = any
  sensitive   = true
  default     = {}
}

variable "tailscale" {
  description = "Tailscale subnet routers"
  type = object({
    cpu           = number
    memory        = number
    desired_count = number
    auto_approve  = bool
    enabled       = bool
  })
}

variable "app_security_group_id" {
  description = "Security group ID attached to ECS tasks."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for ECS-adjacent resources."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block for Tailscale routing."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used for persistent ECS-mounted storage."
  type        = list(string)
}
