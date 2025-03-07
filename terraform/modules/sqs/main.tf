# Create SQS Queue
resource "aws_sqs_queue" "service_b_queue" {
  name                      = var.queue_name
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 0

  # Enable FIFO if required
  fifo_queue                = var.fifo_queue
  content_based_deduplication = var.fifo_queue

  tags = {
    Name = var.queue_name
  }
}
