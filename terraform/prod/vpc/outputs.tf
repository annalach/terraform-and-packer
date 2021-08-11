output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "public_subnets_ids" {
  value       = module.vpc.public_subnets_ids
  description = "IDs of Public Subnets"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "IDs of Private Subnets"
}

output "public_subnets_cidr_blocks" {
  value       = module.vpc.public_subnets_cidr_blocks
  description = "Public Subnets' CIDR blocks"
}

output "private_subnets_cidr_blocks" {
  value       = module.vpc.private_subnets_cidr_blocks
  description = "Private Subnets' CIDR blocks"
}
