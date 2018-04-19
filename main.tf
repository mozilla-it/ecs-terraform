# Remote state
terraform {
  backend "s3" {
    bucket = "webops-ecs-terraform"
    region = "us-east-1"
    key    = "terraform.tfstate"
  }
}

provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "${var.aws_profile}"
}
