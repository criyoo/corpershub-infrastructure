project_name               = "corpershub"
environment                = "prod"
region                     = "eu-west-1"
acm_region                 = "us-east-1"
account_id                 = "709147557965" # Account has gone live, so do NOT change
root_account_id            = "656111643297"
assume_role                = "Admin"
root_domain_name           = "corpershub.ng"
domain_name                = "corpershub.ng"
api_domain_name            = "api.corpershub.ng"
vpc_cidr                   = "10.20.0.0/16"
container_architecture     = "ARM64"
enable_waf                 = false
enable_container_insights  = false
enable_deletion_protection = true
log_retention_in_days      = 14
manage_root_email_dns      = false

# ECS Services
api = {
  cpu           = 1024
  memory        = 2048
  desired_count = 1
  min_count     = 1
  max_count     = 2
  cpu_target    = 80
  enabled       = true # When 'false', this will disable all ecs services, cloufront, Alb, Valkey cache and R53 records
}

workers = {
  cpu                    = 256
  memory                 = 512
  desired_count          = 1
  schedule_expression    = "rate(3 minutes)" # EventBridge calls the API every 5 minutes, and the API queues the cleanup job for the worker.
  enabled                = true
  enable_async_otp_email = true
}

tailscale = {
  cpu           = 256
  memory        = 512
  desired_count = 1
  auto_approve  = true
  enabled       = false
}

# Database
database = {
  instance_class          = "db.t4g.medium"
  allocated_storage       = 20
  max_allocated_storage   = 500
  backup_retention_period = 7
  multi_az                = false
  deletion_protection     = true
  skip_final_snapshot     = false
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
