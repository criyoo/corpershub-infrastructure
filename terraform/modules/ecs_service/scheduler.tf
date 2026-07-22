data "aws_iam_policy_document" "payment_expiry_eventbridge_assume_role" {
  for_each = local.payment_expiry_eventbridge_definitions

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_cloudwatch_event_connection" "payment_expiry" {
  for_each = local.payment_expiry_eventbridge_definitions

  name               = "${var.name_prefix}-${each.value.name_suffix}"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = each.value.header_name
      value = each.value.header_value
    }
  }
}

resource "aws_cloudwatch_event_api_destination" "payment_expiry" {
  for_each = local.payment_expiry_eventbridge_definitions

  name                             = "${var.name_prefix}-${each.value.name_suffix}"
  connection_arn                   = aws_cloudwatch_event_connection.payment_expiry[each.key].arn
  invocation_endpoint              = each.value.invocation_endpoint
  http_method                      = "POST"
  invocation_rate_limit_per_second = 1
}

resource "aws_iam_role" "payment_expiry_eventbridge" {
  for_each = local.payment_expiry_eventbridge_definitions

  name               = "${var.name_prefix}-${each.value.name_suffix}-eventbridge"
  assume_role_policy = data.aws_iam_policy_document.payment_expiry_eventbridge_assume_role[each.key].json

  tags = var.common_tags
}

data "aws_iam_policy_document" "payment_expiry_eventbridge" {
  for_each = local.payment_expiry_eventbridge_definitions

  statement {
    sid     = "InvokePaymentExpiryApiDestination"
    actions = ["events:InvokeApiDestination"]
    resources = [
      aws_cloudwatch_event_api_destination.payment_expiry[each.key].arn,
    ]
  }
}

resource "aws_iam_role_policy" "payment_expiry_eventbridge" {
  for_each = local.payment_expiry_eventbridge_definitions

  name   = "${var.name_prefix}-${each.value.name_suffix}-eventbridge"
  role   = aws_iam_role.payment_expiry_eventbridge[each.key].id
  policy = data.aws_iam_policy_document.payment_expiry_eventbridge[each.key].json
}

resource "aws_cloudwatch_event_rule" "payment_expiry" {
  for_each = local.payment_expiry_eventbridge_definitions

  name                = "${var.name_prefix}-${each.value.name_suffix}"
  schedule_expression = each.value.schedule_expression
  state               = "ENABLED"

  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "payment_expiry" {
  for_each = local.payment_expiry_eventbridge_definitions

  rule     = aws_cloudwatch_event_rule.payment_expiry[each.key].name
  arn      = aws_cloudwatch_event_api_destination.payment_expiry[each.key].arn
  role_arn = aws_iam_role.payment_expiry_eventbridge[each.key].arn
  input    = jsonencode({})

  http_target {
    header_parameters = {
      "Content-Type" = "application/json"
    }
  }

  retry_policy {
    maximum_event_age_in_seconds = 300
    maximum_retry_attempts       = 2
  }
}
