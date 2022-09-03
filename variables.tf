variable "node_version" {
  type    = number
  default = 16

  validation {
    condition = contains([12, 14, 16], var.node_version)
    error_message = "Must be a valid lambda node runtime version"
  }
}

variable "python_version" {
  type    = string
  default = "3.9"

  validation {
    condition = contains(["3.6", "3.7", "3.8", "3.9"])
    error_message = "Must be a valid lambda python runtime version"
  }
}

variable "cicd_role" {
  type = string
}

variable "lambda_bucket" {
  type = string
}

variable "runtime" {
  type    = string
  default = "node"
  validation {
    condition = contains(["node", "python"], var.runtime)
    error_message = "Must be node or python"
  }
}

variable "repo" {
  type = string
}

variable "branch" {
  type    = string
  default = "main"
}

variable "function_name" {
  type = string
}

variable "description" {
  type    = string
  default = ""
}

variable "handler" {
  type    = string
  default = ""
}

variable "log_retention_in_days" {
  type    = number
  default = 14
}

variable "environment" {
  type    = map(string)
  default = {}
}