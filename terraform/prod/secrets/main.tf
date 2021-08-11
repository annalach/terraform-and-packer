provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

module "secrets" {
  source = "../../modules/secrets"

  environment_name = "prod"
}
