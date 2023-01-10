variable "bus_name" {
  type        = string
  description = "Name of the bus to receive events from"
}

variable "targets" {
  type = object({
    lambda = optional(set(string), [])
    bus    = optional(set(string), [])
  })

  validation {
    condition     = alltrue([for arn in var.targets.lambda : can(regex("arn:aws:lambda:[a-z,0-9,-]+:\\d{12}:function:", arn))])
    error_message = "The lambda set may only contain lambda ARNs."
  }

  validation {
    condition     = alltrue([for arn in var.targets.bus : can(regex("arn:aws:events:[a-z,0-9,-]+:\\d{12}:event-bus/", arn))])
    error_message = "The bus set may only contain event bus ARNs."
  }

  description = "Targets to route event to, mapped by target type"
}

variable "event_pattern" {
  type        = string
  description = "Event pattern to listen for on source bus"
}

locals {
  lambda_names = toset([for arn in var.targets.lambda : reverse(split(":", arn))[0]])
}
