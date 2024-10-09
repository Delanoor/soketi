output "ecs_cluster_id" {
  description = "The ECS cluster ID"
  value       = aws_ecs_cluster.soketi.id
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.soketi.name
}
