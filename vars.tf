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

variable "target_type" {
  type    = string
  default = "lambda"

  validation {
    condition     = contains(["lambda", "bus"], var.target_type)
    error_message = "Invalid `target_type` given. Valid values are 'lambda' or 'bus'."
  }
}
