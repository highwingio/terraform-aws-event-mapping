terraform {
  required_version = ">= 0.14.0"
}

provider "aws" {
  region = "us-east-1"
}

module "appsync_explicit" {
  source   = "../../"
  bus_name = "the-knight-bus"
  event_patterns = [
    "event.FightBasilisk",
  ]

  targets = {
    appsync = {
      phoenix : {
        arn : "arn:aws:appsync:us-east-1:123456789012:apis/fawkes-phoenix"
        http_url : "https://lotsofdigitsandchars.appsync-api.us-east-1.amazonaws.com/graphql"

        template : file("${path.module}/gql/request.json")
        template_vars = {
          location : "$.detail.location"
          urgency : "$.detail.urgency"
          bring : "$.detail.bring",
          healing : "$.detail.phoenix_tears"
        }

        operation : "createEmergency"
        response_template : <<EOF
{
  message
  status
  eta
}
EOF
      }
    }
  }
}

module "appsync_passthru" {
  source   = "../../"
  bus_name = "the-knight-bus"
  event_patterns = [
    "event.SockGiven",
  ]

  targets = {
    appsync = {
      dobby : {
        arn : "arn:aws:appsync:us-east-1:123456789012:apis/house-elf-dobby"
        http_url : "https://randomstringofcharacters.appsync-api.us-east-1.amazonaws.com/graphql"

        passthrough : true
        operation : "freeDobby"
        response_template : <<EOF
{
  message
  status
  sockColor
}
EOF
      }
    }
  }
}
