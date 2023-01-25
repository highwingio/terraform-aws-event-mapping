terraform {
  required_version = ">= 0.14.0"
}

provider "aws" {
  region = "us-east-1"
}

module "named_event_mapping" {
  source         = "../"
  bus_name       = "the-knight-bus"
  rule_name      = "getSum"
  event_patterns = ["event.DementorsAppear"]

  targets = {
    bus = [
      "arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic"
    ],
    lambda = [
      "arn:aws:lambda:us-east-1:123456789012:function:summonPatronus"
    ]
  }
}

module "missing_one" {
  source         = "../"
  bus_name       = "the-knight-bus"
  event_patterns = ["event.BoggartAppear"]

  targets = {
    lambda = [
      "arn:aws:lambda:us-east-1:123456789012:function:summonPatronus",
      "arn:aws:lambda:us-east-1:123456789012:function:summonRon",
      "arn:aws:lambda:us-east-1:123456789012:function:summonHermione"
    ]
  }
}

module "multi_event" {
  source   = "../"
  bus_name = "the-knight-bus"
  event_patterns = [
    "event.RevokeHogsmeadePass",
    "event.AssignDetention"
  ]

  targets = {
    bus = [
      "arn:aws:events:us-east-1:123456789012:event-bus/drinkButterBeer",
      "arn:aws:events:us-east-1:123456789012:event-bus/useInvisibilityCloak"
    ]
  }
}