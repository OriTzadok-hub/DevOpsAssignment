output "ecs_cluster_id" {
  description = "The ID of the ECS Cluster"
  value       = aws_ecs_cluster.main_cluster.id
}

output "ecs_tasks_sg_id" {
  value = aws_security_group.ecs_tasks.id
}

output "service_a_log_group" {
  value       = aws_cloudwatch_log_group.service_a.name
  description = "CloudWatch log group for Service A logs"
}

output "service_a_response_time_metric" {
  value       = var.service_a_latency_metric_name
  description = "CloudWatch metric name for Service A response time"
}