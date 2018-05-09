# Create ECS cluster service

resource "aws_ecs_service" "redirects" {
  name            = "redirects"
  cluster         = "${aws_ecs_cluster.webops-cluster.id}"
  task_definition = "${aws_ecs_task_definition.redirects.arn}"
  desired_count   = 0
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

# ECR configuration

resource "aws_ecr_repository" "webops-redirect-server" {
  name = "webops-redirect-server"
}
