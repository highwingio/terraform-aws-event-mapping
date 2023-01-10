variable "bus_name" {
  type        = string
  description = "Name of the bus to receive events from"
}

variable "targets" {
  type = set(string)
  description = "Targets to route event to"
}

variable "event_pattern" {
  type        = string
  description = "Event pattern to listen for on source bus"
}

locals {
  lambda_names = toset(compact([for arn in var.targets : startswith(arn, "arn:aws:lambda")
    ? element(split(":", arn), length(split(":", arn))-1)
    : ""]))
}
