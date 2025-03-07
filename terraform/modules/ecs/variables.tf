# ECS Cluster Configuration
variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "main-cluster"
}

variable "environment" {
  description = "Environment tag (production/staging/dev)"
  type        = string
  default     = "production"
}

# Networking & Security
variable "vpc_id" {
  description = "VPC ID from the VPC module"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where ECS tasks will run"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security Group ID for Application Load Balancer"
  type        = string
}

# IAM Roles for ECS Tasks
variable "ecs_execution_role_arn" {
  description = "ARN for ECS Task Execution IAM role"
  type        = string
}

variable "frontend_task_role_arn" {
  description = "ARN of IAM role assigned to the frontend ECS tasks"
  type        = string
}

variable "service_a_task_role_arn" {
  description = "ARN of IAM role assigned to Service A ECS tasks"
  type        = string
}

variable "service_b_task_role_arn" {
  description = "ARN of IAM role assigned to Service B ECS tasks"
  type        = string
}

# Application Load Balancer Configuration
variable "alb_target_group_arn" {
  description = "ARN of ALB target group for frontend ECS service"
  type        = string
}

# Frontend Service Configuration
variable "frontend_image" {
  description = "Docker image URL for frontend container"
  type        = string
}

variable "frontend_desired_count" {
  description = "Desired number of frontend ECS tasks"
  type        = number
  default     = 2
}

# Service A Configuration
variable "service_a_image" {
  description = "Docker image URL for Service A container"
  type        = string
}

variable "service_a_desired_count" {
  description = "Desired number of Service A ECS tasks"
  type        = number
  default     = 2
}

# Service B Configuration (SQS Consumer)
variable "service_b_image" {
  description = "Docker image URL for Service B container"
  type        = string
}

variable "service_b_desired_count" {
  description = "Desired number of Service B ECS tasks"
  type        = number
  default     = 1
}

# Autoscaling Configuration (SQS Queue for Service B)
variable "sqs_queue_arn" {
  description = "ARN of the SQS queue used to scale ECS service B"
  type        = string
}

variable "sqs_queue_url" {
  description = "URL of the SQS queue used by Service B"
  type        = string
}

variable "mongodb_uri" {
  description = "MongoDB connection string"
  type        = string
}

variable "service_a_max_capacity" {
  description = "Maximum number of tasks for service-a"
  type        = number
  default     = 10
}

variable "service_a_min_capacity" {
  description = "Minimum number of tasks for service-a"
  type        = number
  default     = 1
}

variable "service_a_latency_threshold" {
  description = "Threshold for service-a response time (in seconds)"
  type        = number
  default     = 0.5  # 500ms
}

# CloudWatch Log Group for Service A
variable "service_a_log_group_name" {
  description = "CloudWatch log group for Service A logs"
  type        = string
  default     = "/aws/ecs/service-a"
}

# CloudWatch Metric Name for Service A Latency
variable "service_a_latency_metric_name" {
  description = "Custom CloudWatch metric name for Service A response time"
  type        = string
  default     = "Custom/ServiceA/ServiceAResponseTime"
}




