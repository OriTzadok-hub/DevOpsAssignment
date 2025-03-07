# ARN of the SQS queue for frontend to send messages to Service B
variable "sqs_queue_arn" {
  description = "ARN of the SQS queue for Service B"
  type        = string
}