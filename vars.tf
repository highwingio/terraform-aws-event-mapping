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

variable "targets" {
  type = object({
    lambda = optional(map(string), {})
    bus    = optional(map(string), {})
    sqs    = optional(map(string), {})
    event_api = optional(map(object({
      endpoint : string,
      token : string,
      template_vars = optional(map(string), {}),
      template      = string,
    })), {})
  })

  validation {
    condition = alltrue([
      for name, arn in var.targets.lambda : can(regex("arn:aws:lambda:[a-z,0-9,-]+:\\d{12}:function:", arn))
    ])
    error_message = "The lambda set may only contain lambda ARNs."
  }

  validation {
    condition = alltrue([
      for name, arn in var.targets.bus : can(regex("arn:aws:events:[a-z,0-9,-]+:\\d{12}:event-bus/", arn))
    ])
    error_message = "The bus set may only contain event bus ARNs."
  }

  validation {
    condition     = alltrue([for name, arn in var.targets.sqs : can(regex("arn:aws:sqs:[a-z,0-9,-]+:\\d{12}:", arn))])
    error_message = "The sqs set may only contain sqs queue ARNs."
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
  type        = map(list(string))
  description = "Filters to apply against the event `detail`s. Must be a valid content filter (see https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns-content-based-filtering.html)"
  default     = null
}

locals {
  #  lambda_names = toset([for arn in var.targets.lambda : reverse(split(":", arn))[0]])
  name        = var.rule_name == null ? var.event_patterns[0] : var.rule_name
  all_pattern = var.all_events ? [{ prefix : "" }] : []
  filters     = var.filters == null ? {} : { detail = var.filters }
}
