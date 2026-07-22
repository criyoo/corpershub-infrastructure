output "database_endpoint" {
  description = "RDS endpoint hostname."
  value       = aws_db_instance.postgres.address
}

output "database_password" {
  description = "RDS master password."
  value       = random_password.master.result
  sensitive   = true
}


output "rds_instance_status" {
  description = "RDS instance status."
  value       = aws_db_instance.postgres.status
}

output "valkey_endpoint" {
  description = "Valkey primary endpoint hostname."
  value = try(
    coalesce(
      aws_elasticache_replication_group.valkey["main"].primary_endpoint_address,
      aws_elasticache_replication_group.valkey["main"].configuration_endpoint_address
    ),
    null
  )
}

output "valkey_url" {
  description = "Valkey connection URL for the application, using the Redis protocol."
  value = try(
    format(
      "redis://%s:6379/0",
      coalesce(
        aws_elasticache_replication_group.valkey["main"].primary_endpoint_address,
        aws_elasticache_replication_group.valkey["main"].configuration_endpoint_address
      )
    ),
    null
  )
}
