locals {
  valkey_enabled = var.api.enabled
}

resource "aws_elasticache_subnet_group" "valkey" {
  for_each = local.valkey_enabled ? { main = true } : {}

  name       = "${var.name_prefix}-valkey"
  subnet_ids = var.private_subnet_ids
}

resource "aws_elasticache_replication_group" "valkey" {
  for_each = local.valkey_enabled ? { main = true } : {}

  replication_group_id       = replace("${var.name_prefix}-valkey", "_", "-")
  description                = "Valkey cache and broker for ${var.name_prefix}"
  engine                     = "valkey"
  engine_version             = var.cache.engine_version
  node_type                  = var.cache.node_type
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.valkey[each.key].name
  security_group_ids         = [var.valkey_security_group_id]
  automatic_failover_enabled = var.cache.replica_count > 0
  multi_az_enabled           = var.cache.replica_count > 0 && var.cache.multi_az
  num_cache_clusters         = var.cache.replica_count + 1
  at_rest_encryption_enabled = true
  transit_encryption_enabled = false
  apply_immediately          = var.environment != "prod"

  tags = var.common_tags
}
