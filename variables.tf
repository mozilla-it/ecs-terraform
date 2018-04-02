variable "region" {
    description = "The AWS region to create resources in."
    default = "us-east-1"
}

variable "availability_zone1" {
    description = "The first availability zone"
    default = "us-east-1a"
}

variable "availability_zone2" {
    description = "The second availability zone"
    default = "us-east-1b"
}

variable "instance_type" {
    description = "EC2 instance size"
    default = "t2.micro"
}

variable "service_name" {
  default = "webops-test-service"
}

variable "github_token" {}

variable "source_repository" {
  type    = "map"
  default = {
    "https_url"   = "https://github.com/mozilla-it/redirects-aws.git",
    "owner"       = "mozilla-it"
    "name"        = "redirects-aws"
    "branch"      = "master"
  }
}

variable "webops_tags" {
  type = "map"
  default = {
    ServiceName      = "webops-testing"
    TechnicalContact = "infra-webops@mozilla.com"
    Environment      = "prod"
    Purpose          = "website"
  }
}

variable "description" {
  default = "A random description"
}
