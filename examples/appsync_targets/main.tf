terraform {
  required_version = ">= 0.14.0"
}

provider "aws" {
  region = "us-east-1"
}

module "appsync_action" {
  source   = "../../"
  bus_name = "the-knight-bus"
  event_patterns = [
    "event.FightBasilisk",
  ]

  targets = {
    appsync = {
      phoenix : {
        arn : "arn:aws:appsync:us-east-1:123456789012:apis/fawkes-phoenix"

        template : file("${path.module}/gql/request.json")
        template_vars = {
          location: "$.detail.location"
          urgency: "$.detail.urgency"
          bring: "$.detail.bring",
          healing: "$.detail.phoenix_tears"
        }

        operation: "createEmergency",
        response_template: <<EOF
{
  message
  status
  eta
}
EOF
      }
    }
  }
}
