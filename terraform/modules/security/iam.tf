# IAM policy for CloudFront to access S3 bucket
data "aws_iam_policy_document" "web_bucket_access" {
  statement {
    sid    = "AllowCloudFrontRead"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = [
      "${var.web_bucket_arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [coalesce(var.cloudfront_distribution_arn, "arn:aws:cloudfront::disabled:distribution/disabled")]
    }
  }
}
