resource "aws_lb" "this" {
  for_each = local.api_ingress_enabled ? { main = true } : {}

  name                       = substr("${var.name_prefix}-alb", 0, 32)
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.alb_security_group_id]
  subnets                    = [for subnet in aws_subnet.public : subnet.id]
  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-alb"
  })
}

resource "aws_lb_target_group" "api" {
  for_each = local.api_ingress_enabled ? { main = true } : {}

  name        = substr("${var.name_prefix}-api", 0, 32)
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.this.id

  health_check {
    enabled             = true
    path                = "/healthz/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    matcher             = "200-399"
  }

  tags = var.common_tags
}

resource "aws_lb_listener" "http" {
  for_each = local.api_ingress_enabled ? { main = true } : {}

  load_balancer_arn = aws_lb.this[each.key].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  for_each = local.api_ingress_enabled ? { main = true } : {}

  load_balancer_arn = aws_lb.this[each.key].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.alb_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      message_body = jsonencode({ detail = "Host not found." })
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "api_host" {
  for_each = local.api_ingress_enabled ? { main = true } : {}

  listener_arn = aws_lb_listener.https[each.key].arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api[each.key].arn
  }

  condition {
    host_header {
      values = [var.api_domain_name]
    }
  }
}

resource "aws_wafv2_web_acl_association" "api" {
  for_each = var.enable_waf && local.api_ingress_enabled ? { single = true } : {}

  resource_arn = aws_lb.this["main"].arn
  web_acl_arn  = var.web_acl_arn
}
