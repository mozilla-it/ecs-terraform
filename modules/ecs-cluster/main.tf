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

  ami           = "${data.aws_ami.latest.id}"
  instance_type = "t2.micro"
  user_data     = "${data.template_file.user_data.rendered}"
}
