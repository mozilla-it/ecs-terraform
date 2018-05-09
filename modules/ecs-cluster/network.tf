# Network configuration

resource "aws_vpc" "cluster-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_route_table" "cluster-route" {
  vpc_id = "${aws_vpc.cluster-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ecs-nat-gw.id}"
  }
}

resource "aws_subnet" "ecs-subnet1" {
  vpc_id            = "${aws_vpc.cluster-vpc.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.availability_zone1}"
}

resource "aws_nat_gateway" "ecs-nat-gw" {
  allocation_id = "${aws_eip.ecs-nat-eip.id}"
  subnet_id     = "${aws_subnet.ecs-subnet1.id}"
}

resource "aws_eip" "ecs-nat-eip" {
  vpc = true
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

resource "aws_security_group" "ec2-sg" {
  name        = "ec2-sg"
  description = "Allows HTTP traffic"
  vpc_id      = "${aws_vpc.cluster-vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  timeouts {
    delete = "5m"
  }
}
