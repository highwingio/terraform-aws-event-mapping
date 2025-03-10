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
  state          = var.enabled ? "ENABLED" : "DISABLED"

  event_pattern = jsonencode(merge({
    detail-type : concat(var.event_patterns, local.all_pattern)
  }, local.filters, local.not_accounts, local.accounts))
}

# handles the target mapping for targets that require an IAM role
resource "aws_cloudwatch_event_target" "event_target_with_role" {
  for_each = setunion(var.targets.bus, var.targets.sfn)

  arn            = each.value
  role_arn       = aws_iam_role.event_role[0].arn
  rule           = aws_cloudwatch_event_rule.event_rule.name
  event_bus_name = var.bus_name

  retry_policy {
    maximum_event_age_in_seconds = var.maximum_event_age_in_seconds
    maximum_retry_attempts       = var.retry_attempts
  }

  dead_letter_config {
    arn = aws_sqs_queue.dlq.arn
  }
}

# handles the target mapping for targets that prohibit using IAM roles
resource "aws_cloudwatch_event_target" "event_target_without_role" {
  for_each = setunion(var.targets.lambda, var.targets.sqs)

  target_id      = reverse(split(":", each.value))[0]
  arn            = each.value
  rule           = aws_cloudwatch_event_rule.event_rule.name
  event_bus_name = var.bus_name

  retry_policy {
    maximum_event_age_in_seconds = var.maximum_event_age_in_seconds
    maximum_retry_attempts       = var.retry_attempts
  }

  dead_letter_config {
    arn = aws_sqs_queue.dlq.arn
  }
}

resource "aws_sqs_queue" "dlq" {
  name = "${reverse(split(".", local.name))[0]}-dlq"
}

resource "aws_lambda_permission" "permission" {
  for_each = var.targets.lambda

  action        = "lambda:InvokeFunction"
  function_name = reverse(split(":", each.value))[0]
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule.arn
}
