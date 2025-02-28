locals {
  passthru_template = "{ \"input\": <input> }"
  passthru_vars = {
    input : "$.detail"
  }
}

resource "aws_cloudwatch_event_target" "appsync" {
  for_each = var.targets.appsync

  target_id      = each.key
  rule           = aws_cloudwatch_event_rule.event_rule.name
  arn            = "arn:aws:appsync:us-east-1:${data.aws_arn.gql_arns[each.key].account}:endpoints/graphql-api/${regex("https://(\\w+)\\..+", each.value.http_url)[0]}"
  role_arn       = aws_iam_role.event_role[0].arn
  event_bus_name = var.bus_name

  input_transformer {
    input_paths    = each.value.passthrough ? local.passthru_vars : each.value.template_vars
    input_template = each.value.passthrough ? local.passthru_template : each.value.template
  }

  appsync_target {
    graphql_operation = "mutation ${title(each.value.operation)}($input: ${title(each.value.operation)}Input!) { ${each.value.operation}(input: $input) ${each.value.response_template}}"
  }

  retry_policy {
    maximum_retry_attempts = var.retry_attempts
  }

  dead_letter_config {
    arn = aws_sqs_queue.dlq.arn
  }
}
