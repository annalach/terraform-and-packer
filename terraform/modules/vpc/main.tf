terraform {
  required_version = ">= 0.14.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment_name} VPC"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets_cidr_blocks)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnets_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.environment_name} - Public Subnet - ${var.public_subnets_cidr_blocks[count.index]}"
  }
}

resource "aws_subnet" "private_subnets" {
  count = length(var.public_subnets_cidr_blocks)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.environment_name} - Private Subnet - ${var.private_subnets_cidr_blocks[count.index]}"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment_name} - IG for VPC"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "${var.environment_name} - Public Route Table for VPC"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public_subnets)

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "vpc_endpoint" {
  vpc_id      = aws_vpc.vpc.id
  description = " ${var.environment_name} - SG for VPC Endpoint"

  tags = {
    Name = "${var.environment_name} -  SG for VPC Endpoint"
  }

  ingress {
    description = "Allow HTTPS from instances from Private Subnets"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = aws_subnet.private_subnets.*.cidr_block
  }
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.eu-central-1.secretsmanager"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  subnet_ids = aws_subnet.private_subnets.*.id

  private_dns_enabled = true
}
