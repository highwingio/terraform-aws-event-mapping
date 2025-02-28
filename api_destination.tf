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

resource "aws_cloudwatch_event_target" "event_api" {
  for_each = var.targets.event_api

  target_id      = each.key
  rule           = aws_cloudwatch_event_rule.event_rule.name
  arn            = aws_cloudwatch_event_api_destination.destination[each.key].arn
  role_arn       = aws_iam_role.event_role[0].arn
  event_bus_name = var.bus_name

  input_transformer {
    input_paths    = each.value.template_vars
    input_template = each.value.template
  }

  retry_policy {
    maximum_retry_attempts = var.retry_attempts
  }

  dead_letter_config {
    arn = aws_sqs_queue.dlq.arn
  }
}
