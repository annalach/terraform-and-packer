terraform {
  required_version = ">= 0.14.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    "path" = "${var.vpc_state_path}"
  }
}

data "terraform_remote_state" "secrets" {
  backend = "local"

  config = {
    "path" = "${var.secrets_state_path}"
  }
}

data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = data.terraform_remote_state.secrets.outputs.db_secert_arn
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.environment_name}-rds"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  tags = {
    Name = "${var.environment_name} RDS"
  }
}

resource "aws_security_group" "rds" {
  name   = "${var.environment_name}-rds"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks
  }

  tags = {
    Name = "${var.environment_name} RDS"
  }
}

resource "aws_db_parameter_group" "rds" {
  name   = "${var.environment_name}-rds"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "rds" {
  identifier             = "${var.environment_name}-rds"
  instance_class         = "db.t3.micro"
  allocated_storage      = var.allocated_storage
  engine                 = "postgres"
  engine_version         = "13.1"
  name                   = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string).name
  username               = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string).username
  password               = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string).password
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.rds.name
  multi_az               = var.multi_az
  skip_final_snapshot    = true # to be able to delete RDS instance without creating DB snapshot
}
