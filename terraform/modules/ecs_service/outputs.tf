output "cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.this.name
}

output "service_names" {
  description = "ECS service names."
  value = merge(
    {
      for key, service in aws_ecs_service.service :
      key => service.name
    },
    {
      for key, service in aws_ecs_service.tailscale :
      key => service.name
    }
  )
}

output "migration_task_definition_arn" {
  description = "Task definition ARN for one-off migrations."
  value       = aws_ecs_task_definition.migration.arn
}
