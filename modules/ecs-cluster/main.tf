# Create a new cluster

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.cluster_name}-${var.environment}-cluster"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/userdata.sh")}"

  vars {
    environment  = "${var.environment}"
    cluster_name = "${var.cluster_name}"
  }
}

resource "aws_iam_role" "ecs" {
  name = "ecs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ecs_for_ec2" {
  name       = "ecs-for-ec2"
  roles      = ["${aws_iam_role.ecs.id}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs" {
  name  = "ecs-profile"
  roles = ["${aws_iam_role.ecs.name}"]
}

data "aws_ami" "latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "ecs_instance" {
  count = "2"

  ami                         = "${data.aws_ami.latest.id}"
  instance_type               = "t2.micro"
  user_data                   = "${data.template_file.user_data.rendered}"
  subnet_id                   = "${aws_subnet.ecs-subnet1.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs.id}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.ec2-sg.id}"]
}
