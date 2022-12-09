variable "bus_name" {
  type        = string
  description = "Name of the bus to receive events from"
}

variable "target_arn" {
  type        = string
  description = "Target to route event to"
}

variable "event_pattern" {
  type        = string
  description = "Event pattern to listen for on source bus"
}

variable "source_type" {
  type    = string
  default = "lambda"

  validation {
    condition     = contains(["lambda", "bus"], var.source_type)
    error_message = "Invalid `source_type` given '${var.source_type}'. Valid values are 'lambda' or 'bus'."
  }
}
