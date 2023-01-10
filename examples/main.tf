terraform {
  required_version = ">= 0.14.0"
}

provider "aws" {
  region = "us-east-1"
}

module "event_mapping" {
  source        = "../"
  bus_name      = "the-night-bus"
  event_pattern = "event.DementorsAppear"

  targets = [
    "arn:aws:lambda:us-east-1:123456789012:function:summonPatronus",
    "arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic"
  ]
}