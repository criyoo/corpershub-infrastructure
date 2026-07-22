variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "common_tags" {
  description = "Tags applied to database resources."
  type        = map(string)
}

variable "environment" {
  description = "Environment name."
  type        = string
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

variable "cache" {
  description = "ElastiCache settings."
  type = object({
    node_type      = string
    engine_version = string
    replica_count  = number
    multi_az       = bool
  })
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used for data services."
  type        = list(string)
}

variable "postgres_security_group_id" {
  description = "Security group ID attached to PostgreSQL."
  type        = string
}

variable "valkey_security_group_id" {
  description = "Security group ID attached to Valkey."
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
