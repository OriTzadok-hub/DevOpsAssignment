output "ecs_execution_role_arn" {
  description = "IAM Execution role ARN for ECS tasks"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "frontend_role_arn" {
  description = "Frontend ECS task IAM role ARN"
  value       = aws_iam_role.frontend_task_role.arn
}

output "service_a_role_arn" {
  description = "Service A ECS task IAM role ARN"
  value       = aws_iam_role.service_a_task_role.arn
}

output "service_b_role_arn" {
  description = "Service B ECS task IAM role ARN"
  value       = aws_iam_role.service_b_task_role.arn
}
