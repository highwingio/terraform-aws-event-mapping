variable "bus_name" {
  type        = string
  description = "Name of the bus to receive events from"
}

variable "rule_name" {
  type        = string
  description = "Unique name to give the event rule. If empty, will use the first event pattern. Required if using `all_events`"
  default     = null
}

variable "enabled" {
  type        = bool
  description = "Enable or disable the event mapping"
  default     = true
}

variable "retry_attempts" {
  type    = number
  default = 5
}

variable "exclude_self" {
  type        = bool
  description = "Exclude the calling account's events"
  default     = false
}

variable "targets" {
  type = object({
    lambda = optional(set(string), [])
    bus    = optional(set(string), [])
    sqs    = optional(set(string), [])
    sfn    = optional(set(string), [])
    event_api = optional(map(object({
      endpoint : string,
      token : string,
      template_vars : optional(map(string), {}),
      template : string,
    })), {})
    appsync = optional(map(object({
      arn : string,
      http_url : string,
      operation : string
      passthrough : optional(bool, false),
      template_vars : optional(map(string), {}),
      template : optional(string),
      response_template : string
    })), {})
  })

  validation {
    condition = alltrue([
      for arn in var.targets.lambda : can(regex("arn:aws:lambda:[a-z,0-9,-]+:\\d{12}:function:", arn))
    ])
    error_message = "The lambda set may only contain lambda ARNs."
  }

  validation {
    condition = alltrue([
      for arn in var.targets.bus : can(regex("arn:aws:events:[a-z,0-9,-]+:\\d{12}:event-bus/", arn))
    ])
    error_message = "The bus set may only contain event bus ARNs."
  }

  validation {
    condition     = alltrue([for arn in var.targets.sqs : can(regex("arn:aws:sqs:[a-z,0-9,-]+:\\d{12}:", arn))])
    error_message = "The sqs set may only contain sqs queue ARNs."
  }

  validation {
    condition = alltrue([
      for arn in var.targets.sfn : can(regex("arn:aws:states:[a-z,0-9,-]+:\\d{12}:stateMachine:", arn))
    ])
    error_message = "The sfn set may only contain step function ARNs."
  }

  description = "Targets to route event to, mapped by target type"
}

variable "event_patterns" {
  type        = list(string)
  default     = []
  description = "Event patterns to listen for on source bus."
}

variable "all_events" {
  type        = bool
  default     = false
  description = "Trigger on any event. Ignores `event_patterns` if specified."
}

variable "filters" {
  type        = map(any)
  description = "Filters to apply against the event `detail`s. Must be a valid content filter (see [docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns-content-based-filtering.html))"
  default     = null
}

variable "allow_accounts" {
  type        = list(string)
  description = "Allowed accounts. Will override `ignore_accounts` if present."
  default     = []

  validation {
    condition     = alltrue([for id in var.allow_accounts : can(regex("\\d{12}", id))])
    error_message = "Please provide valid account IDs"
  }
}

variable "ignore_accounts" {
  type        = list(string)
  description = "Ignored accounts. Will be overridden by `allow_accounts` if present."
  default     = []

  validation {
    condition     = alltrue([for id in var.ignore_accounts : can(regex("\\d{12}", id))])
    error_message = "Please provide valid account IDs"
  }
}

locals {
  name            = var.rule_name == null ? var.event_patterns[0] : var.rule_name
  all_pattern     = var.all_events ? [{ prefix : "" }] : []
  filters         = var.filters == null ? {} : { detail = var.filters }
  accounts        = length(var.allow_accounts) == 0 ? {} : { account = var.allow_accounts }
  ignore_accounts = var.exclude_self ? concat(var.ignore_accounts, [data.aws_caller_identity.self.account_id]) : var.ignore_accounts
  not_accounts    = length(local.ignore_accounts) == 0 ? {} : { account = [{ "anything-but" : local.ignore_accounts }] }
}
