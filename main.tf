/**
 * # terraform-aws-event-mapping
 * Terraform module to map EventBridge bus events to other target resources
 *
 * ## Usage
 *
 * ```hcl
 * module "event_mapping" {
 *   source             = "highwingio/event-mapping/aws"
 *   # Other arguments here...
 * }
 * ```
 *
 * ## Updating the README
 *
 * This repo uses [terraform-docs](https://github.com/segmentio/terraform-docs) to autogenerate its README.
 *
 * To regenerate, run this command:
 *
 * ```bash
 * $ terraform-docs markdown table . > README.md
 * ```
 */

resource "aws_cloudwatch_event_rule" "event_rule" {
  name           = local.name
  event_bus_name = var.bus_name
  is_enabled     = var.enabled

  event_pattern = jsonencode(merge({
    detail-type : concat(var.event_patterns, local.all_pattern)
  }, local.filters, local.not_accounts, local.accounts))
}

# handles the target mapping for lambdas, buses, and sqs (event_api is more complex)
resource "aws_cloudwatch_event_target" "event_target" {
  for_each = merge(var.targets.lambda, var.targets.bus, var.targets.sqs)

  arn            = each.value
  rule           = aws_cloudwatch_event_rule.event_rule.name
  event_bus_name = var.bus_name
}

resource "aws_lambda_permission" "permission" {
  for_each = var.targets.lambda

  action        = "lambda:InvokeFunction"
  function_name = each.key
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule.arn
}
