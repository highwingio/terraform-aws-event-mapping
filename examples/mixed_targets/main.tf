terraform {
  required_version = ">= 0.14.0"
}

provider "aws" {
  region = "us-east-1"
}

module "multi-target" {
  source   = "../../"
  bus_name = "the-knight-bus"

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

module "added-filters" {
  source   = "../../"
  bus_name = "the-knight-bus"

  event_patterns = ["event.SpellCast"]

  filters = {
    type  = ["curse"],
    class = ["unforgivable"]
  }

  targets = {
    bus = [
      "arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic"
    ],
    lambda = [
      "arn:aws:lambda:us-east-1:123456789012:function:Duck",
      "arn:aws:lambda:us-east-1:123456789012:function:Dodge",
      "arn:aws:lambda:us-east-1:123456789012:function:Weave",
    ]
  }
}