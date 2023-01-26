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

  event_pattern = jsonencode({
    detail-type : var.event_patterns
  })
}

# handles the target mapping for lambdas and buses (event_api is more complex)
resource "aws_cloudwatch_event_target" "event_target" {
  for_each = setunion(var.targets.lambda, var.targets.bus)

  arn            = each.key
  rule           = aws_cloudwatch_event_rule.event_rule.name
  event_bus_name = var.bus_name
}

resource "aws_lambda_permission" "permission" {
  for_each = local.lambda_names

  action        = "lambda:InvokeFunction"
  function_name = each.key
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule.arn
}
