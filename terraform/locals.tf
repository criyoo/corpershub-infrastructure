locals {
  name_prefix     = "${var.project_name}-${var.environment}"
  database        = merge(var.database, { enabled = var.api.enabled && var.database.enabled })
  tailscale       = merge(var.tailscale, { enabled = var.api.enabled && var.tailscale.enabled })
  workers         = merge(var.workers, { enabled = var.api.enabled && var.workers.enabled && var.workers.enable_async_otp_email })
  async_otp_email = var.workers.enable_async_otp_email && var.workers.enabled && var.api.enabled
  payment_expiry_trigger_token = sha256(
    "${trimspace(lookup(var.api_secure_parameters, "DJANGO_SECRET_KEY", ""))}:payment-expiry-scheduler"
  )

  flutterwave_api_base_url = var.environment == "dev" ? "https://developersandbox-api.flutterwave.com" : "https://f4bexperience.flutterwave.com"
  flutterwave_api_verion   = var.environment == "dev" ? "v3" : "v4"

  autoscaling_services = var.api.enabled ? {
    api = {
      min_capacity = var.api.min_count
      max_capacity = var.api.max_count
      cpu_target   = var.api.cpu_target
    }
  } : {}

  api_allowed_hosts   = join(",", distinct(concat([var.api_domain_name], ["localhost", "127.0.0.1"])))
  route53_zone_id     = data.aws_route53_zone.main.zone_id
  media_custom_domain = module.storage.media_bucket_domain_name
  api_image_uri       = "${module.storage.api_repository.repository_url}:${var.environment}"

  migration_parameters_hash = sha1(jsonencode({
    for key, value in nonsensitive(local.filtered_api_secure_parameters) :
    key => value if trimspace(value) != "" && key != "TAILSCALE_AUTHKEY"
  }))

  filtered_api_secure_parameters = {
    for key, value in var.api_secure_parameters :
    key => value if trimspace(nonsensitive(value)) != ""
  }

  api_string_parameters = merge(
    {
      DJANGO_SETTINGS_MODULE    = var.environment == "dev" ? "config.settings.development" : "config.settings.production"
      DJANGO_ALLOWED_HOSTS      = local.api_allowed_hosts
      DJANGO_SUPERUSER_EMAIL    = "admin@${var.domain_name}"
      DJANGO_SUPERUSER_USERNAME = "admin@${var.domain_name}"

      # Application settings
      WEB_URL                      = "https://${var.domain_name}"
      CORS_ALLOW_ALL_ORIGINS       = "false"
      CORS_ALLOWED_ORIGINS         = "https://${var.domain_name}"
      CORS_ALLOW_CREDENTIALS       = "true"
      CSRF_TRUSTED_ORIGINS         = "https://${var.domain_name},https://${var.api_domain_name}"
      AUTH_REFRESH_COOKIE_PATH     = "/"
      AUTH_REFRESH_COOKIE_SAMESITE = "Lax"
      AUTH_REFRESH_COOKIE_SECURE   = "true"
      AUTH_REFRESH_COOKIE_NAME     = "corpershub_${var.environment}_refresh"
      SEED_DEMO_ACCOUNTS           = var.environment == "dev" ? "true" : "false"

      # Database settings
      POSTGRES_DB             = var.database.name
      POSTGRES_USER           = var.database.username
      POSTGRES_HOST           = module.databases.database_endpoint
      POSTGRES_PORT           = "5432"
      AWS_STORAGE_BUCKET_NAME = module.storage.media_bucket.bucket
      AWS_S3_REGION_NAME      = var.region
      AWS_S3_CUSTOM_DOMAIN    = local.media_custom_domain

      # Email Settings
      DEFAULT_FROM_EMAIL        = "noreply@corpershub.ng"
      EMAIL_BACKEND             = "django.core.mail.backends.smtp.EmailBackend"
      EMAIL_FROM_EMAIL          = "info@corpershub.ng"
      EMAIL_HOST                = "smtp.hostinger.com"
      EMAIL_PORT                = "587"
      EMAIL_HOST_USER           = "info@corpershub.ng"
      EMAIL_USE_TLS             = "true"
      EMAIL_USE_SSL             = "false"
      EMAIL_TIMEOUT             = "60"
      SERVER_EMAIL              = "info@corpershub.ng"
      JWT_ACCESS_MINUTES        = "60"
      JWT_REFRESH_DAYS          = "7"
      OTP_EXPIRY_SECONDS        = "600"
      OTP_RESEND_WINDOW_SECONDS = "60"
      OTP_MAX_ATTEMPTS          = "5"
      OTP_EMAIL_ASYNC           = tostring(local.async_otp_email)

      # Verification API for NIN and CAC
      VERIFICATION_SERVICE                 = "prembly"
      DIKRIPT_API_BASE_URL                 = "https://api.dikript.com"
      DIKRIPT_NIN_API_URL                  = "/dikript/verification/api/v1/getnin"
      DIKRIPT_CAC_API_URL                  = "/dikript/verification/api/v1/getcacbasic"
      DIKRIPT_TIMEOUT_SECONDS              = "30"
      PREMBLY_API_BASE_URL                 = "https://api.prembly.com"
      PREMBLY_NIN_API_URL                  = "/verification/vnin"
      PREMBLY_CAC_API_URL                  = "/verification/cac"
      PREMBLY_TIMEOUT_SECONDS              = "30"
      PREMBLY_LOOKUP_CACHE_TIMEOUT_SECONDS = "86400"
      PREMBLY_WEBHOOK_TOKEN_CACHE_SECONDS  = "604800"
      PREMBLY_CAC_COMPANY_TYPE             = "RC"

      # Keep these aligned with Flutterwave Dashboard > Settings > Business preferences.
      FLUTTERWAVE_API_VERSION                    = local.flutterwave_api_verion
      FLUTTERWAVE_SETTLEMENT_BANK_NAME           = "Providus Bank"
      FLUTTERWAVE_SETTLEMENT_ACCOUNT_NUMBER      = "1309659188"
      FLUTTERWAVE_V3_API_BASE_URL                = "https://api.flutterwave.com/v3"
      FLUTTERWAVE_API_BASE_URL                   = local.flutterwave_api_base_url
      FLUTTERWAVE_WEBHOOK_URL                    = "https://${var.api_domain_name}/api/payments/webhooks/flutterwave/"
      FLUTTERWAVE_TOKEN_URL                      = "https://idp.flutterwave.com/realms/flutterwave/protocol/openid-connect/token"
      FLUTTERWAVE_VIRTUAL_ACCOUNT_EXPIRY_SECONDS = 3600
    },
    var.api.enabled ? {
      VALKEY_URL = module.databases.valkey_url
    } : {}
  )

  api_secure_parameters = merge(local.filtered_api_secure_parameters, {
    POSTGRES_PASSWORD = module.databases.database_password
  })
}

locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}
