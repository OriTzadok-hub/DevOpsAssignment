variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs where the ALB should be deployed"
  type        = list(string)
}

variable "ssl_certificate_arn" {
  description = "The ARN of the SSL certificate for HTTPS listener"
  type        = string
}

variable "frontend_target_group_name" {
  description = "Name for the frontend target group"
  type        = string
  default     = "frontend-tg"
}

variable "cloudfront_cidr" {
  description = "Allowed CIDR block for CloudFront distribution"
  type        = string
}

