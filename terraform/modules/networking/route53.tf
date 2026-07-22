resource "aws_route53_record" "web" {
  for_each = local.web_distribution_enabled ? { main = true } : {}

  provider = aws.root

  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "web_ipv6" {
  for_each = local.web_distribution_enabled ? { main = true } : {}

  provider = aws.root

  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api" {
  for_each = local.api_ingress_enabled ? { main = true } : {}

  provider = aws.root

  zone_id = var.hosted_zone_id
  name    = var.api_domain_name
  type    = "A"

  alias {
    name                   = aws_lb.this[each.key].dns_name
    zone_id                = aws_lb.this[each.key].zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "api_ipv6" {
  for_each = local.api_ingress_enabled ? { main = true } : {}

  provider = aws.root

  zone_id = var.hosted_zone_id
  name    = var.api_domain_name
  type    = "AAAA"

  alias {
    name                   = aws_lb.this[each.key].dns_name
    zone_id                = aws_lb.this[each.key].zone_id
    evaluate_target_health = true
  }
}
