# Create a new cluster

resource "aws_ecs_cluster" "webops-cluster" {
  name = "webops-cluster-production"
}

# Create a new task definition

resource "aws_ecs_task_definition" "redirects" {
  family = "redirects"

  container_definitions = <<DEFINITION
[
  {
    "cpu": 128,
    "essential": true,
    "image": "httpd:latest",
    "memory": 128,
    "memoryReservation": 64,
    "name": "redirects"
  }
]
DEFINITION
}

# Create ECS cluster service

resource "aws_ecs_service" "redirects" {
  name            = "redirects"
  cluster         = "${aws_ecs_cluster.webops-cluster.id}"
  task_definition = "${aws_ecs_task_definition.redirects.arn}"
  desired_count   = 0
}

# ECR configuration

resource "aws_ecr_repository" "webops-redirect-server" {
  name = "webops-redirect-server"
}

# Network configuration

resource "aws_lb" "ecs-redirects-alb" {
  name            = "ecs-lb-tf"
  internal        = false
  security_groups = ["${aws_security_group.redirects_lb_sg.id}"]
  subnets         = ["${aws_subnet.ecs-redirects-subnet1.id}", "${aws_subnet.ecs-redirects-subnet2.id}"]

  enable_deletion_protection = false

  tags {
    Project        = "redirects-ecs"
    Environment    = "dev"
    TechnicalOwner = "infra-webops@mozilla.com"
  }
}

resource "aws_vpc" "ecs-redirects-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    Project        = "redirects-ecs"
    Environment    = "dev"
    TechnicalOwner = "infra-webops@mozilla.com"
  }
}

resource "aws_route_table" "redirects-rt-external" {
  vpc_id = "${aws_vpc.ecs-redirects-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ecs-redirects-ig.id}"
  }

  tags {
    Project        = "redirects-ecs"
    Environment    = "dev"
    TechnicalOwner = "infra-webops@mozilla.com"
  }
}

resource "aws_subnet" "ecs-redirects-subnet1" {
  vpc_id            = "${aws_vpc.ecs-redirects-vpc.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.availability_zone1}"

  tags {
    Project        = "redirects-ecs"
    Environment    = "dev"
    TechnicalOwner = "infra-webops@mozilla.com"
  }
}

resource "aws_subnet" "ecs-redirects-subnet2" {
  vpc_id            = "${aws_vpc.ecs-redirects-vpc.id}"
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.availability_zone2}"

  tags {
    Project        = "redirects-ecs"
    Environment    = "dev"
    TechnicalOwner = "infra-webops@mozilla.com"
  }
}

resource "aws_route_table_association" "redirects-rt-assoc1" {
  subnet_id      = "${aws_subnet.ecs-redirects-subnet1.id}"
  route_table_id = "${aws_route_table.redirects-rt-external.id}"
}

resource "aws_route_table_association" "redirects-rt-assoc2" {
  subnet_id      = "${aws_subnet.ecs-redirects-subnet2.id}"
  route_table_id = "${aws_route_table.redirects-rt-external.id}"
}

resource "aws_internet_gateway" "ecs-redirects-ig" {
  vpc_id = "${aws_vpc.ecs-redirects-vpc.id}"

  tags {
    Project        = "redirects-ecs"
    Environment    = "dev"
    TechnicalOwner = "infra-webops@mozilla.com"
  }
}

resource "aws_security_group" "redirects_lb_sg" {
  name        = "redirects_lb_sg"
  description = "Allows all traffic"
  vpc_id      = "${aws_vpc.ecs-redirects-vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  timeouts {
    delete = "5m"
  }

  tags {
    Project        = "redirects-ecs"
    Environment    = "dev"
    TechnicalOwner = "infra-webops@mozilla.com"
  }
}
