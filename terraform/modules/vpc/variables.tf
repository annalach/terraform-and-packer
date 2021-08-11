variable "environment_name" {
  description = "The name of the environment"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The VPC cidr block"
  type        = string
}

variable "public_subnets_cidr_blocks" {
  description = "Public subnets cidr blocks"
  type        = list(string)
}

variable "private_subnets_cidr_blocks" {
  description = "Private subnets cidr blocks"
  type        = list(string)
}
