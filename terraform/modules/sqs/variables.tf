variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = "service-b-queue"
}

variable "fifo_queue" {
  description = "Enable FIFO queue"
  type        = bool
  default     = false
}
