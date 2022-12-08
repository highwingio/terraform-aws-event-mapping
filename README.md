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

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.event_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_lambda_permission.permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bus_name"></a> [bus\_name](#input\_bus\_name) | Name of the bus to receive events from | `string` | n/a | yes |
| <a name="input_event_pattern"></a> [event\_pattern](#input\_event\_pattern) | Event pattern to listen for on source bus | `string` | n/a | yes |
| <a name="input_source_type"></a> [source\_type](#input\_source\_type) | n/a | `string` | `"lambda"` | no |
| <a name="input_target_arn"></a> [target\_arn](#input\_target\_arn) | Target to route event to | `string` | n/a | yes |

## Outputs

No outputs.
