# TODO: expand http_method options
resource "aws_cloudwatch_event_api_destination" "destination" {
  for_each = var.targets.event_api

  name                             = "${local.name}-${each.key}"
  invocation_endpoint              = each.value.endpoint
  http_method                      = "POST"
  invocation_rate_limit_per_second = 20
  connection_arn                   = aws_cloudwatch_event_connection.connection[each.key].arn
}

# TODO: expand auth types available
resource "aws_cloudwatch_event_connection" "connection" {
  for_each = var.targets.event_api

  name               = "${local.name}-${each.key}"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "Authorization"
      value = "Bearer ${each.value.token}"
    }
  }
}

data "aws_iam_policy_document" "event_api_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "api_event_invoke" {
  statement {
    actions = [
      "events:InvokeApiDestination"
    ]
    resources = [for k, v in aws_cloudwatch_event_api_destination.destination : v.arn]
  }
}

resource "aws_iam_policy" "api_event_invoke" {
  count = length(var.targets.event_api) > 0 ? 1 : 0

  name   = local.name
  policy = data.aws_iam_policy_document.api_event_invoke.json
}

resource "aws_iam_role" "api_event" {
  count = length(var.targets.event_api) > 0 ? 1 : 0

  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.event_api_assume_role.json

  managed_policy_arns = [
    aws_iam_policy.api_event_invoke[0].arn
  ]
}

resource "aws_cloudwatch_event_target" "event_api" {
  for_each = var.targets.event_api

  rule           = aws_cloudwatch_event_rule.event_rule.name
  arn            = aws_cloudwatch_event_api_destination.destination[each.key].arn
  role_arn       = aws_iam_role.api_event[0].arn
  event_bus_name = var.bus_name

  input_transformer {
    input_paths    = each.value.template_vars
    input_template = each.value.template
  }
}