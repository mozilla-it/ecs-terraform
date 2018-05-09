# Create a new cluster

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.cluster_name}-${var.environment}-cluster"
}

# Network configuration

resource "aws_vpc" "cluster-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_route_table" "cluster-route" {
  vpc_id = "${aws_vpc.cluster-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ecs-ig.id}"
  }
}

resource "aws_subnet" "ecs-subnet1" {
  vpc_id            = "${aws_vpc.cluster-vpc.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.availability_zone1}"
}

resource "aws_subnet" "ecs-subnet2" {
  vpc_id            = "${aws_vpc.cluster-vpc.id}"
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.availability_zone2}"
}

resource "aws_route_table_association" "route-assoc1" {
  subnet_id      = "${aws_subnet.ecs-subnet1.id}"
  route_table_id = "${aws_route_table.cluster-route.id}"
}

resource "aws_route_table_association" "route-assoc2" {
  subnet_id      = "${aws_subnet.ecs-subnet2.id}"
  route_table_id = "${aws_route_table.cluster-route.id}"
}

resource "aws_internet_gateway" "ecs-ig" {
  vpc_id = "${aws_vpc.cluster-vpc.id}"
}

resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
  description = "Allows all traffic"
  vpc_id      = "${aws_vpc.cluster-vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  timeouts {
    delete = "5m"
  }
}
