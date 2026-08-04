variable "project_name" {
  description = "Short project identifier used in names and tags."
  type        = string
}

variable "environment" {
  description = "Environment name, for example dev or prod."
  type        = string
}

variable "region" {
  description = "Primary AWS region for workload resources."
  type        = string
}

variable "acm_region" {
  description = "AWS region used for CloudFront ACM certificates."
  type        = string
}

variable "account_id" {
  description = "AWS account ID for the target workload environment."
  type        = string
}

variable "assume_role" {
  description = "Role assumed in the target workload account."
  type        = string
}

variable "root_account_id" {
  description = "AWS account ID that owns shared resources and Terraform state."
  type        = string
}

variable "root_admin_role_name" {
  description = "Optional role name to assume in the root account. Defaults to the workload assume role."
  type        = string
  default     = null
  nullable    = true
}

variable "root_domain_name" {
  description = "Primary public Route 53 hosted zone name."
  type        = string
}

variable "domain_name" {
  description = "Public web hostname for the environment."
  type        = string
}

variable "api_domain_name" {
  description = "Public API hostname for the environment."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the workload VPC."
  type        = string
}

variable "container_architecture" {
  description = "Fargate CPU architecture."
  type        = string
  default     = "ARM64"
}

variable "api" {
  description = "API ECS sizing and autoscaling settings."
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
    cpu                    = number
    memory                 = number
    desired_count          = number
    schedule_expression    = optional(string, "rate(5 minutes)")
    enabled                = bool
    enable_async_otp_email = bool
  })
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
  default = {
    instance_class          = "db.t4g.micro"
    allocated_storage       = 20
    max_allocated_storage   = 50
    backup_retention_period = 1
    multi_az                = false
    deletion_protection     = false
    skip_final_snapshot     = true
    engine_version          = "18.3"
    name                    = "corpershub"
    username                = "corpershub"
    enabled                 = true
  }
}

variable "cache" {
  description = "ElastiCache settings."
  type = object({
    node_type      = string
    engine_version = string
    replica_count  = number
    multi_az       = bool
  })
  default = {
    node_type      = "cache.t4g.micro"
    engine_version = "9.0"
    replica_count  = 1
    multi_az       = false
  }
}

variable "enable_waf" {
  description = "Whether to create and attach a regional WAF for the public API ALB."
  type        = bool
}

variable "enable_container_insights" {
  description = "Whether to enable ECS Container Insights for the cluster."
  type        = bool
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection for ALB and RDS."
  type        = bool
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention for ECS services."
  type        = number
  default     = 30
}

variable "tailscale" {
  description = "Tailscale ECS sizing and subnet-routing settings. auto_approve expects a preauthorized auth key. Only set tags when the auth key and tailnet ACL both permit those advertised tags."
  type = object({
    cpu           = number
    memory        = number
    desired_count = number
    auto_approve  = bool
    enabled       = bool
  })
  default = {
    cpu           = 256
    memory        = 512
    desired_count = 1
    auto_approve  = true
    enabled       = false
  }
}

variable "manage_root_email_dns" {
  description = "Whether this workspace should manage the shared Route 53 records for Hostinger Email."
  type        = bool
}

variable "hostinger_email_dns" {
  description = "Hostinger Email DNS records for the root domain."
  type = object({
    mx_ttl       = number
    spf_ttl      = number
    dmarc_ttl    = number
    dkim_ttl     = number
    mx_records   = list(object({ priority = number, value = string }))
    spf_record   = string
    dmarc_record = string
    dkim_records = map(string)
  })
  default = {
    mx_ttl    = 14400
    spf_ttl   = 3600
    dmarc_ttl = 3600
    dkim_ttl  = 300
    mx_records = [
      { priority = 5, value = "mx1.hostinger.com" },
      { priority = 10, value = "mx2.hostinger.com" },
    ]
    spf_record   = "v=spf1 include:_spf.mail.hostinger.com ~all"
    dmarc_record = "v=DMARC1; p=none"
    dkim_records = {
      "hostingermail-a._domainkey" = "hostingermail-a.dkim.mail.hostinger.com"
      "hostingermail-b._domainkey" = "hostingermail-b.dkim.mail.hostinger.com"
      "hostingermail-c._domainkey" = "hostingermail-c.dkim.mail.hostinger.com"
    }
  }
}

variable "api_secure_parameters" {
  description = "Sensitive application configuration exposed through SSM SecureString parameters."
  type        = map(string)
  sensitive   = true
}

variable "tags" {
  description = "Additional shared tags."
  type        = map(string)
  default     = {}
}
