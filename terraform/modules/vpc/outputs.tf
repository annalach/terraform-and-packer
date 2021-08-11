output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "VPC ID"
}

output "public_subnets_ids" {
  value       = aws_subnet.public_subnets.*.id
  description = "IDs of Public Subnets"
}

output "private_subnet_ids" {
  value       = aws_subnet.private_subnets.*.id
  description = "IDs of Private Subnets"
}

output "public_subnets_cidr_blocks" {
  value       = aws_subnet.public_subnets.*.cidr_block
  description = "Public Subnets' CIDR blocks"
}

output "private_subnets_cidr_blocks" {
  value       = aws_subnet.private_subnets.*.cidr_block
  description = "Private Subnets' CIDR blocks"
}
