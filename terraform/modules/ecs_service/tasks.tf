resource "aws_ecs_task_definition" "service" {
  for_each = local.service_definitions

  family                   = "${var.name_prefix}-${each.key}"
  cpu                      = tostring(each.value.cpu)
  memory                   = tostring(each.value.memory)
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.app_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = templatefile("${path.root}/files/task_definition.json", {
    name          = each.value.container_name
    image         = each.value.image
    region        = var.aws_region
    log_group     = "/ecs/${var.name_prefix}-${each.key}"
    stream_prefix = each.key
    environment = jsonencode([
      for key in sort(keys(each.value.environment)) : {
        name  = key
        value = each.value.environment[key]
      }
    ])
    secrets = jsonencode([
      for key in sort(keys(each.value.secrets)) : {
        name      = key
        valueFrom = each.value.secrets[key]
      }
    ])
    has_port_mappings = each.value.container_port != null
    port_mappings = each.value.container_port == null ? jsonencode([]) : jsonencode([
      {
        containerPort = each.value.container_port
        hostPort      = each.value.container_port
        protocol      = "tcp"
      }
    ])
    has_command      = each.value.command != null
    command          = each.value.command == null ? jsonencode([]) : jsonencode(each.value.command)
    has_health_check = each.value.health_check != null
    has_mount_points = try(each.value.volume, null) != null
    mount_points = try(each.value.volume, null) == null ? jsonencode([]) : jsonencode([
      {
        containerPath = each.value.volume.container_path
        sourceVolume  = each.value.volume.name
        readOnly      = false
      }
    ])
    health_check = each.value.health_check == null ? jsonencode({}) : jsonencode({
      command     = each.value.health_check.command
      interval    = each.value.health_check.interval
      timeout     = each.value.health_check.timeout
      retries     = each.value.health_check.retries
      startPeriod = each.value.health_check.start_period
    })
  })

  dynamic "volume" {
    for_each = try(each.value.volume, null) == null ? [] : [each.value.volume]

    content {
      name = volume.value.name

      efs_volume_configuration {
        file_system_id     = var.aws_efs_file_system_id
        root_directory     = "/"
        transit_encryption = "ENABLED"

        authorization_config {
          access_point_id = var.aws_efs_access_point_id
          iam             = "ENABLED"
        }
      }
    }
  }

  runtime_platform {
    cpu_architecture        = var.container_architecture
    operating_system_family = "LINUX"
  }
  tags = var.common_tags
}


resource "aws_ecs_task_definition" "migration" {
  family                   = "${var.name_prefix}-migration"
  cpu                      = tostring(var.api.cpu)
  memory                   = tostring(var.api.memory)
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.app_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    cpu_architecture        = var.container_architecture
    operating_system_family = "LINUX"
  }

  container_definitions = templatefile("${path.root}/files/task_definition.json", {
    name          = "migration"
    image         = var.api_image_uri
    region        = var.aws_region
    log_group     = "/ecs/${var.name_prefix}-migration"
    stream_prefix = "migration"
    environment = jsonencode([
      for key in sort(keys(local.api_runtime_environment)) : {
        name  = key
        value = local.api_runtime_environment[key]
      }
    ])
    secrets = jsonencode([
      for key in sort(keys(local.migration_parameter_arns)) : {
        name      = key
        valueFrom = local.migration_parameter_arns[key]
      }
    ])
    has_port_mappings = false
    port_mappings     = jsonencode([])
    has_command       = true
    command           = jsonencode(["sh", "-c", "python manage.py migrate --noinput"])
    has_mount_points  = false
    mount_points      = jsonencode([])
    has_health_check  = false
    health_check      = jsonencode({})
  })
  tags = var.common_tags
}
