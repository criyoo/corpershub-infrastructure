variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "common_tags" {
  description = "Tags applied to ECS resources."
  type        = map(string)
}

variable "aws_region" {
  description = "AWS region for logging."
  type        = string
}

variable "container_architecture" {
  description = "Runtime CPU architecture for the tasks."
  type        = string
  default     = "ARM64"
}

variable "enable_container_insights" {
  description = "Whether to enable ECS Container Insights for the cluster."
  type        = bool
  default     = false
}

variable "log_retention_in_days" {
  description = "Retention period for the service log group."
  type        = number
}

variable "vpc_cidr" {
  description = "CIDR block for the workload VPC."
  type        = string
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

variable "workers" {
  description = "Celery worker ECS sizing settings."
  type = object({
    cpu                 = number
    memory              = number
    desired_count       = number
    schedule_expression = optional(string, "rate(5 minutes)")
    enabled             = bool
  })
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

variable "api_image_uri" {
  description = "api container image URI."
  type        = string
}

variable "api_release_version" {
  description = "Version marker that changes when api application code changes."
  type        = string
}

variable "api_string_parameters" {
  description = "api environment variables."
  type        = map(string)
}

variable "api_secure_parameter_arns" {
  description = "api secrets sourced from SSM SecureString parameters."
  type        = map(string)
}

variable "api_secure_parameter_values" {
  description = "Secure application parameter ARNs."
  type        = list(string)
  default     = []
}

variable "autoscaling_services" {
  description = "Autoscaling services configuration."
  type = map(object({
    min_capacity = number
    max_capacity = number
    cpu_target   = number
  }))
  default = {}
}

variable "media_bucket_arn" {
  description = "ARN of the media bucket used by the app."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for ECS-adjacent resources."
  type        = string
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs used for persistent ECS-mounted storage."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used for persistent ECS-mounted storage."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs used by ECS services."
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security group ID attached to ECS tasks."
  type        = string
}

variable "api_domain_name" {
  description = "Public API hostname used for EventBridge-triggered internal jobs."
  type        = string
}

variable "api_target_group_arn" {
  description = "api ALB target group ARN."
  type        = string
  default     = null
  nullable    = true
}

variable "aws_efs_file_system_id" {
  description = "efs file system for storing tailscale state"
  type        = string
}
variable "aws_efs_access_point_id" {
  description = "access point for efs file system"
  type        = string
}
variable "aws_efs_mount_targets" {
  description = "EFS mount targets"
  type        = any
}


variable "database" {
  description = "RDS PostgreSQL settings."
  type = object({
    instance_class          = string
    allocated_storage       = number
    max_allocated_storage   = number
    backup_retention_period = number
    multi_az                = bool
    deletion_protection     = bool
    skip_final_snapshot     = bool
    engine_version          = string
    name                    = string
    username                = string
    enabled                 = bool
  })
}

variable "payment_expiry_trigger_token" {
  description = "Shared secret used by EventBridge to enqueue scheduled payment cleanup through the API."
  type        = string
  sensitive   = true
}
