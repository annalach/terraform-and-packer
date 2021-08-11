provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

module "iam" {
  source = "../../modules/iam"

  environment_name   = "prod"
  secrets_state_path = "../secrets/terraform.tfstate"
}
