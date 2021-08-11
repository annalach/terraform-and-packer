variable "environment_name" {
  description = "The name of the environment"
  type        = string
}

variable "secrets_state_path" {
  description = "The path to the state file of the secrets root module"
  type        = string
}
