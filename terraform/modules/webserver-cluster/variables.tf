variable "environment_name" {
  description = "The name of the environment"
  type        = string
}

variable "vpc_state_path" {
  description = "The path to the state file of the vpc root module"
  type        = string
}

variable "iam_state_path" {
  description = "The path to the state file of the iam root module"
  type        = string
}

variable "secrets_state_path" {
  description = "The path to the state file of the secrets root module"
  type        = string
}

variable "database_state_path" {
  description = "The path to the state file of the database root module"
  type        = string
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "cluster_min_size" {
  description = "Minimum number of EC2 instances in Auto Scaling Group"
  type        = number
  default     = 3
}

variable "cluster_max_size" {
  description = "Maximum number of EC2 instances in Auto Scaling Group"
  type        = number
  default     = 6
}
