# SQS Module

This Terraform module provisions an **Amazon Simple Queue Service (SQS) queue** for **Service B**, enabling asynchronous communication between services.

## Resources

### 1. Amazon SQS Queue

**Resource:** `aws_sqs_queue.service_b_queue`

- Creates an **SQS queue** that allows **Service B** to receive messages.
- Configurable as a **FIFO queue** (optional).
- Supports **message size limits** and **retention policies**.

**Configuration Details:**
- **FIFO Queue Support:** Can be enabled using `var.fifo_queue`.
- **Message Retention:** Messages are kept for `86400` seconds (24 hours).
- **Max Message Size:** Supports messages up to `262144` bytes.
- **Receive Wait Time:** `0` seconds, meaning messages are immediately available.

### 2. SQS Queue Outputs

**Outputs:**
- `queue_url`: The URL of the created SQS queue.
- `queue_arn`: The Amazon Resource Name (ARN) of the queue.

## Variables

| Variable Name  | Description                     | Type    | Default            |
|---------------|---------------------------------|--------|--------------------|
| `queue_name`  | Name of the SQS queue          | string | `service-b-queue`  |
| `fifo_queue`  | Enable FIFO queue (true/false) | bool   | `false`            |

## Outputs

| Output Name  | Description                       |
|-------------|-----------------------------------|
| `queue_url` | The URL of the created SQS queue |
| `queue_arn` | The ARN of the SQS queue         |

## Usage

This module can be called from the root Terraform configuration using:

```hcl
module "sqs" {
  source     = "./modules/sqs"
  queue_name = "service-b-queue"
  fifo_queue = false
}
