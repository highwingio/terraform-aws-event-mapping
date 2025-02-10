resource "aws_cloudwatch_event_target" "appsync" {
  for_each = var.targets.appsync

  target_id      = each.key
  rule           = aws_cloudwatch_event_rule.event_rule.name
  arn            = each.value.arn
  role_arn       = aws_iam_role.event_role[0].arn
  event_bus_name = var.bus_name

  input_transformer {
    input_paths    = each.value.template_vars
    input_template = each.value.template
  }

  appsync_target {
    graphql_operation = "mutation ${title(each.value.operation)}($input: ${title(each.value.operation)}Input!) { ${each.value.operation}(input: $input) ${each.value.response_template}}"
  }
}
