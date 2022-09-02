variable "node_version" {
  type    = number
  default = 16
}

variable "python_version" {
  type    = string
  default = "3.9"
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