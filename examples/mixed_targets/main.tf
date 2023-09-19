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
    lambda = {
      busStop : "arn:aws:lambda:us-east-1:123456789012:function:stopBus",
    }
  }
}

module "multi-target" {
  source   = "../../"
  bus_name = "the-knight-bus"

  event_patterns = ["event.DementorsAppear"]

  targets = {
    sqs = {
      SortingHat : "arn:aws:sqs:us-east-1:123456789012:screamProphecy"
    }
    bus = {
      MinOfMag : "arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic"
    },
    lambda = {
      summonPatronus : "arn:aws:lambda:us-east-1:123456789012:function:summonPatronus",
      blackOut : "arn:aws:lambda:us-east-1:123456789012:function:blackOut"
    }
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

  allow_accounts  = ["123456789012", "098765432109"]
  ignore_accounts = ["2828282828282", "949494949494"] # this should be overwritten by the `allow_accounts` spec as more restrictive

  targets = {
    bus = {
      ministryOfMagic : "arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic"
    },
    lambda = {
      Duck : "arn:aws:lambda:us-east-1:123456789012:function:Duck",
      Dodge : "arn:aws:lambda:us-east-1:123456789012:function:Dodge",
      Weave : "arn:aws:lambda:us-east-1:123456789012:function:Weave",
    }
  }
}

module "any-events" {
  source   = "../../"
  bus_name = "the-knight-bus"

  rule_name  = "CatchAll"
  all_events = true

  targets = {
    bus = {
      ministryOfMagic : "arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic"
    }
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
    bus = {
      ministryOfMagic : "arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic"
    }
  }
}

module "ignored-self" {
  source   = "../../"
  bus_name = "the-knight-bus"

  rule_name    = "IgnoreSelf"
  exclude_self = true

  event_patterns = ["speak:RoomOfRequirement"]

  targets = {
    bus = {
      ministryOfMagic : "arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic"
    }
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
    bus = {
      ministryOfMagic : "arn:aws:events:us-east-1:123456789012:event-bus/ministryOfMagic"
    }
  }
}
