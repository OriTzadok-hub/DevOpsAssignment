output "queue_url" {
  description = "The URL of the SQS queue"
  value       = aws_sqs_queue.service_b_queue.id
}

output "queue_arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.service_b_queue.arn
}
