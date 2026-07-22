module "security" {
  source = "./modules/security"

  providers = {
    aws      = aws
    aws.root = aws.root
    aws.acm  = aws.acm
  }

  name_prefix                 = local.name_prefix
  common_tags                 = local.common_tags
  enable_waf                  = var.enable_waf
  root_domain_name            = var.root_domain_name
  domain_name                 = var.domain_name
  api_domain_name             = var.api_domain_name
  hosted_zone_id              = local.route53_zone_id
  vpc_id                      = module.networking.vpc_id
  web_bucket_arn              = module.storage.web_bucket_arn
  cloudfront_distribution_arn = module.networking.cloudfront_distribution_arn
}

module "networking" {
  source = "./modules/networking"

  providers = {
    aws      = aws
    aws.root = aws.root
  }

  name_prefix                     = local.name_prefix
  common_tags                     = local.common_tags
  environment                     = var.environment
  vpc_cidr                        = var.vpc_cidr
  root_domain_name                = var.root_domain_name
  domain_name                     = var.domain_name
  api_domain_name                 = var.api_domain_name
  hosted_zone_id                  = local.route53_zone_id
  api                             = var.api
  iam_web_bucket_access_policy    = module.security.iam_web_bucket_access_policy
  cloudfront_certificate_arn      = module.security.cloudfront_certificate_arn
  alb_certificate_arn             = module.security.alb_certificate_arn
  web_acl_arn                     = module.security.web_acl_arn
  alb_security_group_id           = module.security.alb_security_group_id
  web_bucket_id                   = module.storage.web_bucket_id
  web_bucket_regional_domain_name = module.storage.web_bucket_regional_domain_name
  enable_waf                      = var.enable_waf
  enable_deletion_protection      = var.enable_deletion_protection
}

module "storage" {
  source = "./modules/storage"

  vpc_cidr              = var.vpc_cidr
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  project_name          = var.project_name
  environment           = var.environment
  account_id            = var.account_id
  name_prefix           = local.name_prefix
  common_tags           = local.common_tags
  tailscale             = var.tailscale
  api_string_parameters = local.api_string_parameters
  api_secure_parameters = local.api_secure_parameters
  app_security_group_id = module.security.app_security_group_id
}

module "databases" {
  source = "./modules/databases"

  name_prefix                = local.name_prefix
  common_tags                = local.common_tags
  environment                = var.environment
  database                   = var.database
  cache                      = var.cache
  api                        = var.api
  private_subnet_ids         = module.networking.private_subnet_ids
  postgres_security_group_id = module.security.postgres_security_group_id
  valkey_security_group_id   = module.security.valkey_security_group_id
}

module "ecs_service" {
  source = "./modules/ecs_service"

  name_prefix                  = local.name_prefix
  environment                  = var.environment
  common_tags                  = local.common_tags
  aws_region                   = var.region
  container_architecture       = var.container_architecture
  enable_container_insights    = var.enable_container_insights
  log_retention_in_days        = var.log_retention_in_days
  vpc_cidr                     = var.vpc_cidr
  api                          = var.api
  workers                      = var.workers
  tailscale                    = var.tailscale
  api_image_uri                = local.api_image_uri
  api_release_version          = var.environment
  api_string_parameters        = local.api_string_parameters
  api_secure_parameter_arns    = module.storage.app_secure_parameter_arns
  api_secure_parameter_values  = values(module.storage.app_secure_parameter_arns)
  autoscaling_services         = local.autoscaling_services
  media_bucket_arn             = module.storage.media_bucket_arn
  vpc_id                       = module.networking.vpc_id
  private_subnet_cidrs         = values(module.networking.private_subnet_cidrs)
  private_subnet_ids           = module.networking.private_subnet_ids
  public_subnet_ids            = module.networking.public_subnet_ids
  app_security_group_id        = module.security.app_security_group_id
  api_domain_name              = var.api_domain_name
  database                     = var.database
  api_target_group_arn         = module.networking.api_target_group_arn
  aws_efs_mount_targets        = module.storage.aws_efs_mount_targets
  aws_efs_access_point_id      = module.storage.aws_efs_access_point_id
  aws_efs_file_system_id       = module.storage.aws_efs_file_system_id
  payment_expiry_trigger_token = local.payment_expiry_trigger_token
}
