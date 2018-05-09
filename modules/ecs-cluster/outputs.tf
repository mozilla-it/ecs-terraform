output "cluster_id" {
  value = "${aws_ecs_cluster.ecs-cluster.id}"
}

output "ecs_subnets" {
  value = "${aws_subnet.ecs-subnet1.id}"
}

output "awsvpc_sg" {
  value = "${aws_security_group.ec2-sg.id}"
}
