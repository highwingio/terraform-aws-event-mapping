locals {
  iam_service_types = ["bus", "event_api", "sfn", "appsync"]
  target_types      = [for k, v in var.targets : k if length(v) > 0]
  needs_iam         = length(setintersection(local.iam_service_types, local.target_types)) > 0
}

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
  count = local.needs_iam ? 1 : 0

  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "sfn_policy" {
  statement {
    actions   = ["states:StartExecution"]
    resources = var.targets.sfn
  }
}

data "aws_iam_policy_document" "bus_policy" {
  statement {
    actions   = ["events:PutEvents"]
    resources = var.targets.bus
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

data "aws_iam_policy_document" "appsync_policy" {
  statement {
    actions = [
      "appsync:GraphQL"
    ]
    resources = [for k, v in var.targets.appsync : "${v.arn}/types/Mutation/fields/${v.operation}"]
  }
}


resource "aws_iam_role_policy" "api_events" {
  count = length(var.targets.event_api) > 0 ? 1 : 0

  name   = "invoke-api"
  role   = aws_iam_role.event_role[0].id
  policy = data.aws_iam_policy_document.api_event_invoke.json
}

resource "aws_iam_role_policy" "bus_events" {
  count = length(var.targets.bus) > 0 ? 1 : 0

  name   = "invoke-bus"
  role   = aws_iam_role.event_role[0].id
  policy = data.aws_iam_policy_document.bus_policy.json
}

resource "aws_iam_role_policy" "sfn_events" {
  count = length(var.targets.sfn) > 0 ? 1 : 0

  name   = "invoke-sfn"
  role   = aws_iam_role.event_role[0].id
  policy = data.aws_iam_policy_document.sfn_policy.json
}

resource "aws_iam_role_policy" "appysnc_events" {
  count = length(var.targets.appsync) > 0 ? 1 : 0

  name   = "invoke-appsync"
  role   = aws_iam_role.event_role[0].id
  policy = data.aws_iam_policy_document.appsync_policy.json
}
