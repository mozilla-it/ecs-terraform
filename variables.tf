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
