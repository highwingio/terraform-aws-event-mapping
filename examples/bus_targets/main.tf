terraform {
  required_version = ">= 0.14.0"
}

provider "aws" {
  region = "us-east-1"
}

module "named_event_mapping" {
  source   = "../../"
  bus_name = "the-knight-bus"
  event_patterns = [
    "event.DementorsAppear",
    "event.UnderAgedMagicDone"
  ]

  targets = {
    bus = ["arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic"]
  }
}
