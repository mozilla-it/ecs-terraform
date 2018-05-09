resource "aws_vpc" "ecs-redirects-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    tags {
        Project = "redirects-ecs"
        Environment = "dev"
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
        Project = "redirects-ecs"
        Environment = "dev"
        TechnicalOwner = "infra-webops@mozilla.com"
    }
}

resource "aws_subnet" "ecs-redirects-subnet1" {
    vpc_id = "${aws_vpc.ecs-redirects-vpc.id}"
    cidr_block = "10.0.2.0/24"
    availability_zone = "${var.availability_zone1}"
    tags {
        Project = "redirects-ecs"
        Environment = "dev"
        TechnicalOwner = "infra-webops@mozilla.com"
    }
}

resource "aws_subnet" "ecs-redirects-subnet2" {
    vpc_id = "${aws_vpc.ecs-redirects-vpc.id}"
    cidr_block = "10.0.3.0/24"
    availability_zone = "${var.availability_zone2}"
    tags {
        Project = "redirects-ecs"
        Environment = "dev"
        TechnicalOwner = "infra-webops@mozilla.com"
    }
}

resource "aws_route_table_association" "redirects-rt-assoc1" {
    subnet_id = "${aws_subnet.ecs-redirects-subnet1.id}"
    route_table_id = "${aws_route_table.redirects-rt-external.id}"
}
resource "aws_route_table_association" "redirects-rt-assoc2" {
    subnet_id = "${aws_subnet.ecs-redirects-subnet2.id}"
    route_table_id = "${aws_route_table.redirects-rt-external.id}"
}

resource "aws_internet_gateway" "ecs-redirects-ig" {
    vpc_id = "${aws_vpc.ecs-redirects-vpc.id}"
    tags {
        Project = "redirects-ecs"
        Environment = "dev"
        TechnicalOwner = "infra-webops@mozilla.com"
    }
}

resource "aws_security_group" "redirects_lb_sg" {
    name = "redirects_lb_sg"
    description = "Allows all traffic"
    vpc_id = "${aws_vpc.ecs-redirects-vpc.id}"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }

    timeouts {
        delete = "5m"
    }

    tags {
        Project = "redirects-ecs"
        Environment = "dev"
        TechnicalOwner = "infra-webops@mozilla.com"
    }
}
