provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

module "database" {
  source = "../../modules/database"

  environment_name   = "prod"
  secrets_state_path = "../secrets/terraform.tfstate"
  vpc_state_path     = "../vpc/terraform.tfstate"
  multi_az           = true
}
