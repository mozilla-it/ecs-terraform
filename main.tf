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

module "ecs-cluster" {
  source             = "./modules/ecs-cluster"
  cluster_name       = "webops"
  environment        = "stage"
  region             = "${var.region}"
  availability_zone1 = "${var.availability_zone1}"
  availability_zone2 = "${var.availability_zone2}"
}
