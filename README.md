# terraform-aws-event-mapping
Terraform module to map EventBridge bus events to other target resources

## Usage

```hcl
module "event_mapping" {
  source             = "highwingio/event-mapping/aws"
  # Other arguments here...
}
```

## Updating the README

This repo uses [terraform-docs](https://github.com/segmentio/terraform-docs) to autogenerate its README.

To regenerate, run this command:

```bash
$ terraform-docs markdown table . > README.md
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.86 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.86.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_api_destination.destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_api_destination) | resource |
| [aws_cloudwatch_event_connection.connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_connection) | resource |
| [aws_cloudwatch_event_rule.event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.appsync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.event_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.event_target_with_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.event_target_without_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.event_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.api_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.appysnc_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.bus_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.sfn_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_permission.permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_caller_identity.self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.api_event_invoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.appsync_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.bus_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sfn_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_all_events"></a> [all\_events](#input\_all\_events) | Trigger on any event. Ignores `event_patterns` if specified. | `bool` | `false` | no |
| <a name="input_allow_accounts"></a> [allow\_accounts](#input\_allow\_accounts) | Allowed accounts. Will override `ignore_accounts` if present. | `list(string)` | `[]` | no |
| <a name="input_bus_name"></a> [bus\_name](#input\_bus\_name) | Name of the bus to receive events from | `string` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Enable or disable the event mapping | `bool` | `true` | no |
| <a name="input_event_patterns"></a> [event\_patterns](#input\_event\_patterns) | Event patterns to listen for on source bus. | `list(string)` | `[]` | no |
| <a name="input_exclude_self"></a> [exclude\_self](#input\_exclude\_self) | Exclude the calling account's events | `bool` | `false` | no |
| <a name="input_filters"></a> [filters](#input\_filters) | Filters to apply against the event `detail`s. Must be a valid content filter (see [docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns-content-based-filtering.html)) | `map(any)` | `null` | no |
| <a name="input_ignore_accounts"></a> [ignore\_accounts](#input\_ignore\_accounts) | Ignored accounts. Will be overridden by `allow_accounts` if present. | `list(string)` | `[]` | no |
| <a name="input_rule_name"></a> [rule\_name](#input\_rule\_name) | Unique name to give the event rule. If empty, will use the first event pattern. Required if using `all_events` | `string` | `null` | no |
| <a name="input_targets"></a> [targets](#input\_targets) | Targets to route event to, mapped by target type | <pre>object({<br>    lambda = optional(set(string), [])<br>    bus    = optional(set(string), [])<br>    sqs    = optional(set(string), [])<br>    sfn    = optional(set(string), [])<br>    event_api = optional(map(object({<br>      endpoint : string,<br>      token : string,<br>      template_vars : optional(map(string), {}),<br>      template : string,<br>    })), {})<br>    appsync = optional(map(object({<br>      arn : string,<br>      operation : string<br>      passthrough : optional(bool, false),<br>      template_vars : optional(map(string), {}),<br>      template : optional(string),<br>      response_template : string<br>    })), {})<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_event_rule_arn"></a> [event\_rule\_arn](#output\_event\_rule\_arn) | n/a |
