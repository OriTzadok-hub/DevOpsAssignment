# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for the main VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# SSL Certificate
variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS"
  type        = string
}

# ECS Configuration
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

# Container Image Configurations
variable "frontend_image" {
  description = "Docker image URL for frontend container"
  type        = string
}

variable "service_a_image" {
  description = "Docker image URL for Service A container"
  type        = string
}

variable "service_b_image" {
  description = "Docker image URL for Service B container"
  type        = string
}

# Desired Task Count
variable "frontend_desired_count" {
  description = "Desired number of frontend ECS tasks"
  type        = number
  default     = 2
}

variable "service_a_desired_count" {
  description = "Desired number of Service A ECS tasks"
  type        = number
  default     = 2
}

variable "service_b_desired_count" {
  description = "Desired number of Service B ECS tasks"
  type        = number
  default     = 1
}

# SQS Queue
variable "queue_name" {
  description = "Name of the SQS queue for Service B"
  type        = string
  default     = "service-b-queue"
}

variable "fifo_queue" {
  description = "Enable FIFO queue for SQS"
  type        = bool
  default     = false
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
  default     = 0.5 # 500ms
}

