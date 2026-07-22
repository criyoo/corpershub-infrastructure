resource "aws_ecs_service" "service" {
  for_each = {
    for key, definition in local.service_definitions :
    key => definition if key != "tailscale"
  }

  name                               = "${var.name_prefix}-${each.key}"
  cluster                            = aws_ecs_cluster.this.arn
  task_definition                    = aws_ecs_task_definition.service[each.key].arn
  desired_count                      = each.value.desired_count
  launch_type                        = "FARGATE"
  enable_execute_command             = true
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = each.value.load_balancer == null ? null : try(each.value.load_balancer.health_check_grace_period_seconds, null)

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    assign_public_ip = true
    subnets          = var.public_subnet_ids
    security_groups  = [var.app_security_group_id]
  }

  dynamic "load_balancer" {
    for_each = each.value.load_balancer == null ? [] : [each.value.load_balancer]

    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = each.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  tags = var.common_tags
}


resource "aws_ecs_service" "tailscale" {
  for_each = {
    for key, definition in local.service_definitions :
    key => definition if key == "tailscale"
  }

  name                               = "${var.name_prefix}-${each.key}"
  cluster                            = aws_ecs_cluster.this.arn
  task_definition                    = aws_ecs_task_definition.service[each.key].arn
  desired_count                      = each.value.desired_count
  launch_type                        = "FARGATE"
  enable_execute_command             = true
  health_check_grace_period_seconds  = null
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    assign_public_ip = true
    subnets          = var.public_subnet_ids
    security_groups  = [var.app_security_group_id]
  }

  tags = var.common_tags
}
