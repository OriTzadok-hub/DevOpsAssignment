# ECS Module

This Terraform module provisions an **Amazon Elastic Container Service (ECS) cluster** using **AWS Fargate** to deploy and manage containerized applications. It includes **ECS Services**, **Task Definitions**, **Autoscaling**, **CloudWatch Logging**, and **Security Groups**.

---

## Resources

### 1. ECS Cluster

**Resource:** `aws_ecs_cluster.main_cluster`

- Creates an ECS cluster named based on `var.cluster_name`.
- **Fargate Capacity Provider** is attached for serverless container execution.
- **Container Insights** is enabled for monitoring.

**Resource:** `aws_ecs_cluster_capacity_providers.main_cluster_capacity`

- Defines **Fargate** as the default capacity provider for the cluster.

---

### 2. ECS Security Group

**Resource:** `aws_security_group.ecs_tasks`

- Allows ECS tasks to **receive traffic from the ALB**.
- **Outbound traffic** is unrestricted (`0.0.0.0/0`).

---

### 3. ECS Services

Each ECS Service runs on **AWS Fargate** and is deployed to **private subnets**.

#### **Frontend ECS Service**
**Resource:** `aws_ecs_service.frontend`

- Runs the **frontend application** inside ECS.
- Exposed via the **Application Load Balancer (ALB)**.
- Uses the **frontend target group** (`var.alb_target_group_arn`).

#### **Service A (gRPC Backend)**
**Resource:** `aws_ecs_service.service_a`

- Runs a **gRPC backend service** inside ECS.
- Communicates with the frontend via **direct gRPC calls**.
- Uses a **private network** and does not connect to ALB.

#### **Service B (SQS Consumer)**
**Resource:** `aws_ecs_service.service_b`

- Listens to an **SQS queue** and processes messages.
- Uses **AWS SQS** for message-driven execution.

---

### 4. Task Definitions

Each ECS Service has a corresponding **Task Definition** that defines its compute, network, and container settings.

#### **Frontend Task Definition**
**Resource:** `aws_ecs_task_definition.frontend`

- Runs the **Next.js frontend**.
- Allocates `512 CPU` and `1024MB` memory.
- Exposes **port 3000**.
- Uses **IAM roles** for execution and logging.

#### **Service A Task Definition**
**Resource:** `aws_ecs_task_definition.service_a`

- Runs a **gRPC backend**.
- Allocates `256 CPU` and `512MB` memory.
- Exposes **port 50051** for gRPC.
- Uses **MongoDB** via the `MONGO_URI` environment variable.

#### **Service B Task Definition**
**Resource:** `aws_ecs_task_definition.service_b`

- Runs a **worker service that processes messages from SQS**.
- Allocates `256 CPU` and `512MB` memory.
- Reads the `SQS_QUEUE_URL` from environment variables.

---

### 5. ECS Autoscaling

**Autoscaling ensures that ECS services dynamically adjust to demand.**

#### **Frontend Scaling (CPU-based)**
**Resource:** `aws_appautoscaling_target.frontend_target`
- **Min tasks:** `2`
- **Max tasks:** `5`
- Scales **based on CPU utilization** (`target_value = 50%`).

#### **Service A Scaling (Latency-based)**
**Resource:** `aws_appautoscaling_target.service_a_target`
- **Min tasks:** `1`
- **Max tasks:** `10`
- Scales **based on response time latency** using **CloudWatch Alarms**.

#### **Service B Scaling (SQS-based)**
**Resource:** `aws_appautoscaling_target.service_b_target`
- **Min tasks:** `1`
- **Max tasks:** `5`
- Scales **based on the number of visible SQS messages**.

---

### 6. CloudWatch Logs

**Resource:** `aws_cloudwatch_log_group.service_a`

- Stores logs for **Service A**.
- Retention is set to `30 days`.

**Resource:** `aws_cloudwatch_log_metric_filter.service_a_response_time`

- Tracks **response time** of Service A.
- Creates a **CloudWatch Metric** for monitoring.

---

## Variables

| Variable Name                | Description                                        | Type         | Default           |
|-----------------------------|----------------------------------------------------|-------------|-------------------|
| `cluster_name`              | Name of the ECS cluster                           | string      | `main-cluster`    |
| `environment`               | Deployment environment (prod/dev/staging)         | string      | `production`      |
| `vpc_id`                    | VPC ID where the cluster is deployed              | string      | -                 |
| `private_subnet_ids`         | List of private subnet IDs                        | list(string) | -                 |
| `alb_sg_id`                 | Security Group ID of the ALB                      | string      | -                 |
| `ecs_execution_role_arn`     | IAM role ARN for ECS execution                    | string      | -                 |
| `frontend_task_role_arn`     | IAM role ARN for Frontend ECS tasks               | string      | -                 |
| `service_a_task_role_arn`    | IAM role ARN for Service A ECS tasks              | string      | -                 |
| `service_b_task_role_arn`    | IAM role ARN for Service B ECS tasks              | string      | -                 |
| `frontend_image`             | Docker image for the frontend                     | string      | -                 |
| `service_a_image`            | Docker image for Service A                        | string      | -                 |
| `service_b_image`            | Docker image for Service B                        | string      | -                 |
| `frontend_desired_count`     | Desired task count for Frontend                   | number      | `2`               |
| `service_a_desired_count`    | Desired task count for Service A                  | number      | `2`               |
| `service_b_desired_count`    | Desired task count for Service B                  | number      | `1`               |
| `sqs_queue_arn`              | ARN of the SQS queue for Service B                | string      | -                 |
| `sqs_queue_url`              | URL of the SQS queue for Service B                | string      | -                 |
| `mongodb_uri`                | MongoDB connection string                         | string      | -                 |
| `service_a_max_capacity`     | Max task count for Service A                      | number      | `10`              |
| `service_a_min_capacity`     | Min task count for Service A                      | number      | `1`               |
| `service_a_latency_threshold` | Latency threshold for scaling Service A (seconds) | number      | `0.5`             |

---

## Outputs

| Output Name                      | Description                                  |
|----------------------------------|----------------------------------------------|
| `ecs_cluster_id`                 | ID of the ECS Cluster                       |
| `ecs_tasks_sg_id`                | Security Group ID for ECS tasks             |
| `service_a_log_group`            | CloudWatch Log Group for Service A          |
| `service_a_response_time_metric` | CloudWatch Metric for Service A Response    |

---

## Usage

This module can be called from the root Terraform configuration using:

```hcl
module "ecs" {
  source                     = "./modules/ecs"
  cluster_name               = "main-cluster"
  environment                = "production"
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  alb_sg_id                  = module.alb.alb_sg_id
  ecs_execution_role_arn     = module.iam.ecs_execution_role_arn
  frontend_task_role_arn     = module.iam.frontend_role_arn
  service_a_task_role_arn    = module.iam.service_a_role_arn
  service_b_task_role_arn    = module.iam.service_b_role_arn
  frontend_image             = "frontend-image-url"
  service_a_image            = "service-a-image-url"
  service_b_image            = "service-b-image-url"
  frontend_desired_count     = 2
  service_a_desired_count    = 2
  service_b_desired_count    = 1
  sqs_queue_arn              = module.sqs.queue_arn
  sqs_queue_url              = module.sqs.queue_url
  mongodb_uri                = "mongodb://your-db-uri"
}
