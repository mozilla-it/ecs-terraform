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
