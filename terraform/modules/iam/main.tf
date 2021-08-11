terraform {
  required_version = ">= 0.14.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

data "terraform_remote_state" "secrets" {
  backend = "local"

  config = {
    "path" = "${var.secrets_state_path}"
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.environment_name}_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment_name}_ec2_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "${var.environment_name}_ec2_policy"
  role = aws_iam_role.ec2_role.id

  policy = <<EOT
{
    "Version" : "2012-10-17",
    "Statement" : {
      "Effect" : "Allow",
      "Action" : "secretsmanager:GetSecretValue",
      "Resource" : "${data.terraform_remote_state.secrets.outputs.db_secert_arn}"
    }
}
EOT
}
