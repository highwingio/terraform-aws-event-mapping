terraform {
  required_version = ">= 0.14.0"
}

provider "aws" {
  region = "us-east-1"
}

module "lambda_targets" {
  source         = "../../"
  bus_name       = "the-knight-bus"
  event_patterns = ["event.MalfoyAttacks"]

  retry_attempts               = 5
  maximum_event_age_in_seconds = 80

  targets = {
    lambda = [
      "arn:aws:lambda:us-east-1:123456789012:function:summonRon",
      "arn:aws:lambda:us-east-1:123456789012:function:summonHermione"
    ]
  }
}

module "multi_events" {
  source    = "../../"
  bus_name  = "the-knight-bus"
  rule_name = "getSomeMagic"
  event_patterns = [
    "event.BoggartAppear",
    "event.DementorAppear"
  ]

  targets = {
    lambda = [
      "arn:aws:lambda:us-east-1:123456789012:function:summonPatronus"
    ]
  }
}
