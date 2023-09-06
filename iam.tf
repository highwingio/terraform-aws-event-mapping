data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "event_role" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "sfn_policy" {
  statement {
    actions   = ["states:StartExecution"]
    resources = values(var.targets.sfn)
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions   = ["lambda:InvokeFunction"]
    resources = values(var.targets.lambda)
  }
}

data "aws_iam_policy_document" "sqs_policy" {
  statement {
    actions   = ["sqs:SendMessage"]
    resources = values(var.targets.sqs)
  }
}

data "aws_iam_policy_document" "bus_policy" {
  statement {
    actions   = ["events:PutEvents"]
    resources = values(var.targets.bus)
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

resource "aws_iam_role_policy" "api_events" {
  count = length(var.targets.event_api) > 0 ? 1 : 0

  name   = "invoke-api"
  role   = aws_iam_role.event_role.id
  policy = data.aws_iam_policy_document.api_event_invoke.json
}

resource "aws_iam_role_policy" "sqs_events" {
  count = length(var.targets.sqs) > 0 ? 1 : 0

  name   = "invoke-sqs"
  role   = aws_iam_role.event_role.id
  policy = data.aws_iam_policy_document.sqs_policy.json
}

resource "aws_iam_role_policy" "lambda_events" {
  count = length(var.targets.lambda) > 0 ? 1 : 0

  name   = "invoke-lambda"
  role   = aws_iam_role.event_role.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy" "bus_events" {
  count = length(var.targets.bus) > 0 ? 1 : 0

  name   = "invoke-bus"
  role   = aws_iam_role.event_role.id
  policy = data.aws_iam_policy_document.bus_policy.json
}

resource "aws_iam_role_policy" "sfn_events" {
  count = length(var.targets.sfn) > 0 ? 1 : 0

  name   = "invoke-sfn"
  role   = aws_iam_role.event_role.id
  policy = data.aws_iam_policy_document.sfn_policy.json
}
