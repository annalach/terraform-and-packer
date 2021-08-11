provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

module "webserver_cluster" {
  source = "../../modules/webserver-cluster"

  environment_name    = "prod"
  vpc_state_path      = "../vpc/terraform.tfstate"
  iam_state_path      = "../iam/terraform.tfstate"
  secrets_state_path  = "../secrets/terraform.tfstate"
  database_state_path = "../database/terraform.tfstate"
  server_port         = 5000
}
