variable "bus_name" {
  type        = string
  description = "Name of the bus to receive events from"
}

variable "targets" {
  type = map(string)

  description = "Targets to route event to. Must specify an `arn = type`. `type` must be one of `lambda` or `bus`."

  validation {
    condition     = alltrue([for arn, type in var.targets : contains(["lambda", "bus"], type)])
    error_message = "Invalid `type` given. Valid values are 'lambda' or 'bus'."
  }
}

variable "event_pattern" {
  type        = string
  description = "Event pattern to listen for on source bus"
}

locals {
  lambda_arns = toset([for arn, target in var.targets : target == "lambda" ? arn : ""])
}