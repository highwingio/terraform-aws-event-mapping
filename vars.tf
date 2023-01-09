variable "bus_name" {
  type        = string
  description = "Name of the bus to receive events from"
}

variable "target_arns" {
  type        = array(string)
  description = "Targets to route event to"
}

variable "event_pattern" {
  type        = string
  description = "Event pattern to listen for on source bus"
}

variable "target_type" {
  type    = string
  default = "lambda"
  description = "Target type to route events to. Must be one of `lambda` or `bus`. All targets specified by `target_arns` must be of the same type."

  validation {
    condition     = contains(["lambda", "bus"], var.target_type)
    error_message = "Invalid `target_type` given. Valid values are 'lambda' or 'bus'."
  }
}
