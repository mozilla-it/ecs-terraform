resource "aws_lb" "ecs-redirects-alb" {
  name            = "ecs-lb-tf"
  internal        = false
  security_groups = ["${aws_security_group.redirects_lb_sg.id}"]
  subnets         = ["${aws_subnet.ecs-redirects-subnet1.id}", "${aws_subnet.ecs-redirects-subnet2.id}"]

  enable_deletion_protection = false

  tags {
        Project = "redirects-ecs"
    Environment = "dev"
    TechnicalOwner = "infra-webops@mozilla.com"
  }
}
