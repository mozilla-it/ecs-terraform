output "cluster_id" {
  value = "${aws_ecs_cluster.ecs-cluster.id}"
}

output "ecs_subnets" {
  value = "${aws_subnet.ecs-subnet1.id}"
}
