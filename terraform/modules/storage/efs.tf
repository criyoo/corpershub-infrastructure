resource "aws_security_group" "tailscale_efs" {
  for_each = var.tailscale.enabled ? { main = true } : {}

  name        = "${var.name_prefix}-tailscale-efs"
  description = "Allows ECS tasks to reach the Tailscale state EFS mount targets."
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from ECS tasks"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-tailscale-efs-sg"
  })
}

resource "aws_efs_file_system" "tailscale_state" {
  for_each = var.tailscale.enabled ? { main = true } : {}

  creation_token = "${var.name_prefix}-tailscale-state"
  encrypted      = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-tailscale-state"
  })
}

resource "aws_efs_access_point" "tailscale_state" {
  for_each = var.tailscale.enabled ? { main = true } : {}

  file_system_id = aws_efs_file_system.tailscale_state["main"].id

  root_directory {
    path = "/tailscale"

    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "0700"
    }
  }

  posix_user {
    gid = 0
    uid = 0
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-tailscale-state-ap"
  })
}

resource "aws_efs_mount_target" "tailscale_state" {
  for_each = var.tailscale.enabled ? { main = true } : {}

  file_system_id  = aws_efs_file_system.tailscale_state["main"].id
  subnet_id       = each.value
  security_groups = [aws_security_group.tailscale_efs["main"].id]
}
