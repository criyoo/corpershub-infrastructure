project_name               = "corpershub"
environment                = "dev"
region                     = "eu-west-1"
acm_region                 = "us-east-1"
account_id                 = "250031965796" # dev@corpershub.ng
root_account_id            = "088668668196" # old root account "656111643297"
assume_role                = "Admin"
root_domain_name           = "corpershub.ng"
domain_name                = "dev.corpershub.ng"
api_domain_name            = "api.dev.corpershub.ng"
vpc_cidr                   = "10.10.0.0/16"
container_architecture     = "ARM64"
enable_waf                 = false
enable_container_insights  = false
enable_deletion_protection = false
log_retention_in_days      = 1
manage_root_email_dns      = false

# ECS Services
api = {
  cpu           = 256
  memory        = 512
  desired_count = 1
  min_count     = 1
  max_count     = 1
  cpu_target    = 80
  enabled       = true # When 'false', this will disable all ecs services, cloudfront, alb, valkey cache, route 53 records & stop the database
}

workers = {
  cpu                    = 256
  memory                 = 512
  desired_count          = 1
  schedule_expression    = "rate(5 minutes)"
  enabled                = false # execute background jobs from the queue e.g. sending OTP asynchronously and processing scheduled payment-expiry jobs
  enable_async_otp_email = false # if false async email is disabled and worker is not used. So if false worker enabled will auto set to false
}

tailscale = {
  cpu           = 256
  memory        = 512
  desired_count = 1
  auto_approve  = true
  enabled       = false
}

# Databases
database = {
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
  enabled                 = true # acceptable values: true or false ("true = start" & "false = stop")
}

cache = {
  node_type      = "cache.t4g.micro"
  engine_version = "9.0"
  replica_count  = 1
  multi_az       = false
}

tags = {
  Project = "corpershub"
  Owner   = "platform"
}
