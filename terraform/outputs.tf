# VPC Outputs
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The list of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

# ALB Outputs
output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = module.alb.alb_arn
}

output "alb_sg_id" {
  description = "The Security Group ID associated with the ALB"
  value       = module.alb.alb_sg_id
}

# ECS Outputs
output "ecs_cluster_id" {
  description = "The ID of the ECS Cluster"
  value       = module.ecs.ecs_cluster_id
}

# IAM Outputs
output "ecs_execution_role_arn" {
  description = "IAM Execution role ARN for ECS tasks"
  value       = module.iam.ecs_execution_role_arn
}

output "frontend_role_arn" {
  description = "IAM Role ARN for frontend ECS service"
  value       = module.iam.frontend_role_arn
}

output "service_a_role_arn" {
  description = "IAM Role ARN for Service A ECS service"
  value       = module.iam.service_a_role_arn
}

output "service_b_role_arn" {
  description = "IAM Role ARN for Service B ECS service"
  value       = module.iam.service_b_role_arn
}

# SQS Outputs
output "sqs_queue_url" {
  description = "URL of the SQS queue for Service B"
  value       = module.sqs.queue_url
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue for Service B"
  value       = module.sqs.queue_arn
}

# CloudFront Outputs
output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = module.cloudfront.cloudfront_distribution_id
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.cloudfront.cloudfront_distribution_domain_name
}
