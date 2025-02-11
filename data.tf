data "aws_caller_identity" "self" {}

data "aws_arn" "gql_arns" {
  for_each = var.targets.appsync

  arn = each.value.arn
}
