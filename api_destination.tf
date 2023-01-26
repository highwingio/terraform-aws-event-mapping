# TODO: expand http_method options
resource "aws_cloudwatch_event_api_destination" "destination" {
  count = length(var.targets.event_api)

  name                             = "${local.name}-${var.targets.event_api[count.index].name}"
  invocation_endpoint              = var.targets.event_api[count.index].endpoint
  http_method                      = "POST"
  invocation_rate_limit_per_second = 20
  connection_arn                   = aws_cloudwatch_event_connection.connection[count.index].arn
}

# TODO: expand auth types available
resource "aws_cloudwatch_event_connection" "connection" {
  count = length(var.targets.event_api)

  name               = "${local.name}-${var.targets.event_api[count.index].name}"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "Authorization"
      value = "Bearer ${var.targets.event_api[count.index].token}"
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
    resources = aws_cloudwatch_event_api_destination.destination.*.arn
  }
}

resource "aws_iam_policy" "api_event_invoke" {
  count = length(var.targets.event_api) > 0 ? 1 : 0

  name   = "eventbridge-slack-access-policy"
  policy = data.aws_iam_policy_document.api_event_invoke.json
}

resource "aws_iam_role" "api_event" {
  count = length(var.targets.event_api) > 0 ? 1 : 0

  name               = "${local.name}-${var.targets.event_api[count.index].name}"
  assume_role_policy = data.aws_iam_policy_document.event_api_assume_role.json

  managed_policy_arns = [
    aws_iam_policy.api_event_invoke[0].arn
  ]
}

resource "aws_cloudwatch_event_target" "event_api" {
  count = length(var.targets.event_api)

  rule           = aws_cloudwatch_event_rule.event_rule.name
  arn            = aws_cloudwatch_event_api_destination.destination[count.index].arn
  role_arn       = aws_iam_role.api_event[0].arn
  event_bus_name = var.bus_name

  input_transformer {
    input_paths    = var.targets.event_api[count.index].template_vars
    input_template = var.targets.event_api[count.index].template
  }
}