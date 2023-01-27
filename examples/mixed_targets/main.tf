terraform {
  required_version = ">= 0.14.0"
}

provider "aws" {
  region = "us-east-1"
}

module "multi_target" {
  source         = "../../"
  bus_name       = "the-knight-bus"
  event_patterns = ["event.DementorsAppear"]

  targets = {
    bus = [
      "arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic"
    ],
    lambda = [
      "arn:aws:lambda:us-east-1:123456789012:function:summonPatronus",
      "arn:aws:lambda:us-east-1:123456789012:function:blackOut"
    ]
  }
}
