# IAM Module

This Terraform module provisions IAM roles and policies required for ECS task execution and communication with AWS services such as SQS.

## Resources

### 1. ECS Task Execution Role

**Resource:** `aws_iam_role.ecs_task_execution_role`

- Role used by ECS tasks to pull images from ECR and send logs to CloudWatch.
- Assumed by `ecs-tasks.amazonaws.com` service.
- **Attached Policy:** `AmazonECSTaskExecutionRolePolicy` via `aws_iam_policy_attachment.ecs_task_execution_policy`.

### 2. Frontend ECS Task Role

**Resource:** `aws_iam_role.frontend_task_role`

- Role assigned to the frontend ECS task.
- Assumed by `ecs-tasks.amazonaws.com`.
- **Policy:** `aws_iam_policy.frontend_sqs_policy`
  - Allows sending messages to an SQS queue for backend communication.
  - Actions allowed: `sqs:SendMessage`.
  - Resource: `var.sqs_queue_arn`.

### 3. Service A ECS Task Role

**Resource:** `aws_iam_role.service_a_task_role`

- Role assigned to Service A ECS task.
- Assumed by `ecs-tasks.amazonaws.com`.
- Standard IAM permissions for its specific functionality.

### 4. Service B ECS Task Role

**Resource:** `aws_iam_role.service_b_task_role`

- Role assigned to Service B ECS task.
- Assumed by `ecs-tasks.amazonaws.com`.
- **Policy:** `aws_iam_policy.service_b_sqs_policy`
  - Allows consuming messages from SQS.
  - Actions allowed: `sqs:ReceiveMessage`, `sqs:DeleteMessage`, `sqs:GetQueueAttributes`.
  - Resource: `var.sqs_queue_arn`.

## Variables

| Variable Name  | Description                                  | Type   |
|---------------|----------------------------------------------|--------|
| `sqs_queue_arn` | ARN of the SQS queue used by Service B | string |

## Outputs

| Output Name               | Description                                  |
|---------------------------|----------------------------------------------|
| `ecs_execution_role_arn`   | ARN of IAM role for ECS task execution      |
| `frontend_role_arn`        | ARN of IAM role for frontend ECS service    |
| `service_a_role_arn`       | ARN of IAM role for Service A ECS service   |
| `service_b_role_arn`       | ARN of IAM role for Service B ECS service   |

## Usage

To use this module, include it in your Terraform configuration as follows:

```hcl
module "iam" {
  source        = "./modules/iam"
  sqs_queue_arn = module.sqs.queue_arn
}
```

## Summary

- **ECS Task Execution Role** allows tasks to pull images and log data.
- **Frontend ECS Role** allows sending messages to SQS.
- **Service A Role** provides required permissions for Service A.
- **Service B Role** allows consuming messages from SQS.
- The module ensures secure IAM policies and role-based access control.

