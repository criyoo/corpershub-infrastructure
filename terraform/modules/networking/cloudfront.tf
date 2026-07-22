resource "aws_cloudfront_origin_access_control" "web" {

  name                              = "${var.name_prefix}-web-oac"
  description                       = "Origin access control for the static web bucket."
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "web_index_rewrite" {

  name    = "${var.name_prefix}-web-index-rewrite"
  comment = "Rewrite exported web routes to index.html objects."
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = <<-EOF
    function handler(event) {
      var request = event.request;
      var uri = request.uri;

      if (uri === "/") {
        request.uri = "/index.html";
        return request;
      }

      if (uri.endsWith("/")) {
        request.uri = uri + "index.html";
        return request;
      }

      if (!uri.split("/").pop().includes(".")) {
        request.uri = uri + "/index.html";
      }

      return request;
    }
  EOF
}

resource "aws_s3_bucket_policy" "web" {

  bucket = var.web_bucket_id
  policy = var.iam_web_bucket_access_policy
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = local.web_distribution_enabled
  is_ipv6_enabled     = true
  comment             = "corpershub ${var.environment}"
  aliases             = [var.domain_name]
  http_version        = "http2and3"
  price_class         = "PriceClass_100"
  wait_for_deployment = true
  default_root_object = "index.html"

  origin {
    domain_name              = var.web_bucket_regional_domain_name
    origin_id                = "web-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.web.id
  }

  default_cache_behavior {
    target_origin_id       = "web-s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.web_index_rewrite.arn
    }
  }

  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.cloudfront_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = var.common_tags
}
