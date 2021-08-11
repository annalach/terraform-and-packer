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

data "terraform_remote_state" "iam" {
  backend = "local"

  config = {
    "path" = "${var.iam_state_path}"
  }
}

data "terraform_remote_state" "secrets" {
  backend = "local"

  config = {
    "path" = "${var.secrets_state_path}"
  }
}

data "terraform_remote_state" "database" {
  backend = "local"

  config = {
    "path" = "${var.database_state_path}"
  }
}

data "aws_ami" "node_app" {
  filter {
    name   = "name"
    values = ["node-app-*"]
  }

  owners      = ["self"]
  most_recent = true
}

resource "aws_security_group" "dmz" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "${var.environment_name} - SG for instances in Public Subnet"

  tags = {
    Name = "${var.environment_name} - DMZ"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "${var.environment_name} - SG for instances in Private Subnet"

  tags = {
    Name = "${var.environment_name} - Private"
  }

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.vpc.outputs.public_subnets_cidr_blocks
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "server" {
  image_id             = data.aws_ami.node_app.id
  instance_type        = "t2.micro"
  iam_instance_profile = data.terraform_remote_state.iam.outputs.ec2_instance_profile_name
  security_groups      = [aws_security_group.private.id]

  user_data = <<-EOF
              #!/bin/bash
              su ubuntu -c 'export PORT=${var.server_port}; export SECRET_ID=${data.terraform_remote_state.secrets.outputs.db_secert_arn}; export DB_ENDPOINT=${data.terraform_remote_state.database.outputs.endpoint}; nohup /home/ubuntu/.nvm/versions/node/v16.3.0/bin/node /home/ubuntu/app/index.js &'
              EOF

  lifecycle {
    # reference used in ASG launch confuguraiton will be updated after creating a new resource and destroying this one
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "asg" {
  name     = "${var.environment_name}-server"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_autoscaling_group" "asg" {
  # Explicitly depend on the launch configuration's name so each time it's replaced, this ASG is also replaced 
  name = "${var.environment_name}-${aws_launch_configuration.server.name}"

  launch_configuration = aws_launch_configuration.server.name
  vpc_zone_identifier  = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = var.cluster_min_size
  max_size = var.cluster_max_size

  # Wait for at least this many instances to pass health checks before # considering the ASG deployment complete
  min_elb_capacity = var.cluster_min_size

  # When replacing this ASG, create the replacement first, and only delete the original after 
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.environment_name} - Instance in Private Subnet"
    propagate_at_launch = true
  }
}

resource "aws_lb" "alb" {
  name               = "${var.environment_name}-alb"
  load_balancer_type = "application"
  subnets            = data.terraform_remote_state.vpc.outputs.public_subnets_ids
  security_groups    = [aws_security_group.dmz.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}
