variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}

variable "alb_origin_id" {
  description = "The origin ID for CloudFront to identify ALB"
  type        = string
}

variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate for CloudFront"
  type        = string
}
