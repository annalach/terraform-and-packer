variable "environment_name" {
  description = "The name of the environment"
  type        = string
}

variable "secrets_state_path" {
  description = "The path to the state file of the secrets root module"
  type        = string
}

variable "vpc_state_path" {
  description = "The path to the state file of the vpc root module"
  type        = string
}

variable "multi_az" {
  description = "Boolean flag to indicate if RDS instance should be Multi-AZ"
  type        = bool
  default     = false
}
