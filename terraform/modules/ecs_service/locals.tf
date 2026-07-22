locals {
  tailscale_extra_args = join(" ", compact(concat(["--advertise-tags=${join(",", ["tag:${var.environment}-subnet-router"])}"], [trimspace("--advertise-routes=${join(",", var.private_subnet_cidrs)}")])))

  api_runtime_environment = merge(var.api_string_parameters, {
    APP_RELEASE_VERSION = var.api_release_version
  })
  migration_parameter_arns = {
    for key, value in var.api_secure_parameter_arns :
    key => value if key != "TAILSCALE_AUTHKEY"
  }
  payment_expiry_eventbridge_definitions = var.api.enabled && var.workers.enabled ? {
    payment_expiry = {
      name_suffix         = "payment-expiry"
      schedule_expression = var.workers.schedule_expression
      invocation_endpoint = "https://${var.api_domain_name}/api/payments/internal/expire-stale/"
      header_name         = "X-Corpershub-Payment-Expiry-Token"
      header_value        = var.payment_expiry_trigger_token
    }
  } : {}

  base_service_definitions = {
    api = {
      cpu            = var.api.cpu
      memory         = var.api.memory
      desired_count  = var.api.desired_count
      image          = var.api_image_uri
      container_name = "api"
      container_port = 8000
      environment    = local.api_runtime_environment
      secrets        = var.api_secure_parameter_arns
      command        = null
      load_balancer = var.api_target_group_arn == null ? null : {
        target_group_arn                  = var.api_target_group_arn
        container_port                    = 8000
        health_check_grace_period_seconds = 90
      }
      health_check = {
        command      = ["CMD-SHELL", "curl -fsS http://localhost:8000/healthz/ || exit 1"]
        interval     = 30
        timeout      = 5
        retries      = 3
        start_period = 60
      }
    }
    worker = {
      cpu            = var.workers.cpu
      memory         = var.workers.memory
      desired_count  = var.workers.desired_count
      image          = var.api_image_uri
      container_name = "worker"
      container_port = null
      environment    = local.api_runtime_environment
      secrets        = var.api_secure_parameter_arns
      command        = ["celery", "-A", "config", "worker", "-l", "info", "--uid=nobody", "--gid=nogroup"]
      load_balancer  = null
      health_check = {
        command      = ["CMD-SHELL", "python -c \"import pathlib,sys; sys.exit(0 if any('celery' in cmd and ' worker ' in f' {cmd} ' for p in pathlib.Path('/proc').glob('[0-9]*/cmdline') for cmd in [p.read_text(errors='ignore').replace(chr(0), ' ')]) else 1)\""]
        interval     = 30
        timeout      = 5
        retries      = 3
        start_period = 60
      }
    }
    tailscale = {
      cpu            = var.tailscale.cpu
      memory         = var.tailscale.memory
      desired_count  = var.tailscale.desired_count
      image          = "tailscale/tailscale:stable"
      container_name = "tailscale"
      container_port = null
      environment = merge(
        {
          TS_ACCEPT_DNS            = "false"
          TS_AUTH_ONCE             = "true"
          TS_HOSTNAME              = "${var.name_prefix}-rds-router"
          TS_ROUTES                = join(",", length(var.private_subnet_cidrs) > 0 ? var.private_subnet_cidrs : [var.vpc_cidr])
          TS_STATE_DIR             = "/var/lib/tailscale"
          TS_TAILSCALED_EXTRA_ARGS = "--tun=userspace-networking"
          TS_USERSPACE             = "true"
          TS_EXTRA_ARGS            = local.tailscale_extra_args
        }
      )
      secrets = {
        TS_AUTHKEY = lookup(var.api_secure_parameter_arns, "TAILSCALE_AUTHKEY", null)
      }
      volume = {
        name           = "tailscale-state"
        container_path = "/var/lib/tailscale"
      }
      command       = null
      load_balancer = null
      health_check = {
        command = [
          "CMD-SHELL",
          "tailscale status --json 2>/dev/null | grep -Eq '\"BackendState\"[[:space:]]*:[[:space:]]*\"Running\"'"
        ]
        interval     = 30
        timeout      = 5
        retries      = 3
        start_period = 90
      }
    }
  }

  service_definitions = merge(
    var.api.enabled ? {
      api = local.base_service_definitions.api
    } : {},
    var.workers.enabled ? {
      worker = local.base_service_definitions.worker
    } : {},
    var.tailscale.enabled ? {
      tailscale = local.base_service_definitions.tailscale
    } : {}
  )

}
