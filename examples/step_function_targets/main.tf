terraform {
  required_version = ">= 0.14.0"
}

provider "aws" {
  region = "us-east-1"
}

module "named_event_mapping" {
  source   = "../../"
  bus_name = "the-knight-bus"

  rule_name = "PolyjuicePotion"

  event_patterns = [
    "command.MakePolyjuicePotion"
  ]

  targets = {
    sfn = {
      PolyJuicer : "arn:aws:states:us-east-1:123456789012:stateMachine:PolyJuicePotion"
    }
  }
}
