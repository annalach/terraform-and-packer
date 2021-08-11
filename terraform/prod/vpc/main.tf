provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

module "vpc" {
  source = "../../modules/vpc"

  environment_name            = "prod"
  vpc_cidr_block              = "10.0.0.0/16"
  public_subnets_cidr_blocks  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"]
}
