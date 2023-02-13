terraform {
  required_version = ">= 0.14.0"
}

provider "aws" {
  region = "us-east-1"
}

locals {
  environment = "testing"
}

module "named_event_mapping" {
  source   = "../../"
  bus_name = "the-knight-bus"
  event_patterns = [
    "event.HogwartsExternal",
    "event.UnderAgedMagicDone",
    "event.ProbablyHarryPotter"
  ]

  targets = {
    event_api = {
      slack : {
        endpoint : "https://hooks.slack.com/services/my/random/key"
        token : "xoxb-rando-tokenizer"

        template = file("${path.module}/message_templates/message-one.json")
        template_vars = {
          submission_uuid = "$.detail.student_name"
        }

      },
      slack-2 : {
        endpoint : "https://hooks.slack.com/services/my/random/key"
        token : "xoxb-rando-tokenizer"
        template = <<EOF
{
  "text": "blah"
}
EOF
      }

    }
  }
}