data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}
