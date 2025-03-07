output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.application_lb.arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.application_lb.dns_name
}

output "alb_sg_id" {
  description = "The Security Group ID for ALB"
  value       = aws_security_group.alb_sg.id
}

output "frontend_tg_arn" {
  description = "The ARN of the frontend target group"
  value       = aws_lb_target_group.frontend_tg.arn
}

output "alb_origin_id" {
  description = "The unique identifier for CloudFront to reference the ALB"
  value       = aws_lb.application_lb.id
}

output "alb_arn_suffix" {
  description = "The ARN suffix of the ALB"
  value       = aws_lb.application_lb.arn_suffix
}


