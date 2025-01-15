terraform {
  required_version = ">= 0.14.0"
}

provider "aws" {
  region = "us-east-1"
}

module "disabled" {
  source   = "../../"
  bus_name = "the-knight-bus"

  enabled        = false
  event_patterns = ["event.HitTheBreaks"]

  targets = {
    lambda = [
      "arn:aws:lambda:us-east-1:123456789012:function:stopBus",
    ]
  }
}

module "multi-target" {
  source   = "../../"
  bus_name = "the-knight-bus"

  event_patterns = ["event.DementorsAppear"]

  targets = {
    sqs = [
      "arn:aws:sqs:us-east-1:123456789012:screamProphecy"
    ]
    bus = [
      "arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic"
    ]
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

  # in the case both `allow_accounts` and `ignore_accounts are both specified
  # the `allow_accounts` will take precedence as the more-restrictive filter
  allow_accounts  = ["123456789012", "098765432109"]
  ignore_accounts = ["2828282828282", "949494949494"]

  targets = {
    bus = ["arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic"],
    lambda = [
      "arn:aws:lambda:us-east-1:123456789012:function:Duck",
      "arn:aws:lambda:us-east-1:123456789012:function:Dodge",
      "arn:aws:lambda:us-east-1:123456789012:function:Weave",
    ]
  }
}

module "any-events" {
  source   = "../../"
  bus_name = "the-knight-bus"

  rule_name  = "CatchAll"
  all_events = true

  targets = {
    bus = [
      "arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic"
    ]
  }
}

data "aws_caller_identity" "self" {}

module "ignored-accounts" {
  source   = "../../"
  bus_name = "the-knight-bus"

  rule_name       = "IgnoreAccounts"
  ignore_accounts = ["2828282828282", "949494949494"]
  exclude_self    = true

  event_patterns = ["speak:RoomOfRequirement"]

  targets = {
    bus = [
      "arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic"
    ]
  }
}

module "ignored-self" {
  source   = "../../"
  bus_name = "the-knight-bus"

  rule_name    = "IgnoreSelf"
  exclude_self = true

  event_patterns = ["speak:RoomOfRequirement"]

  targets = {
    bus = [
      "arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic"
    ]
  }
}

module "nested-filters" {
  source   = "../../"
  bus_name = "the-knight-bus"

  rule_name = "NestingFilters"

  event_patterns = ["cast:spell:unforgivable"]
  filters = {
    punishment = {
      level = {
        strictest = [true]
      }
    }
  }

  targets = {
    bus = [
      "arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic"
    ]
  }
}
