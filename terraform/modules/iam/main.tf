# ECS Task Execution Role (for pulling images & logging)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "ecs_task_execution_policy" {
  name       = "ecs-task-execution-policy-attach"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Role for Frontend Service (allows sending messages to SQS)
resource "aws_iam_role" "frontend_task_role" {
  name = "frontend-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "frontend_sqs_policy" {
  name        = "frontend-sqs-policy"
  description = "Allow frontend to send messages to SQS queue"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = ["sqs:SendMessage"],
      Resource  = var.sqs_queue_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "frontend_sqs_policy_attach" {
  role       = aws_iam_role.frontend_task_role.name
  policy_arn = aws_iam_policy.frontend_sqs_policy.arn
}

# IAM Role for Service A (Standard Permissions)
resource "aws_iam_role" "service_a_task_role" {
  name = "service-a-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# IAM Role for Service B (Allows consuming messages from SQS)
resource "aws_iam_role" "service_b_task_role" {
  name = "service-b-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "service_b_sqs_policy" {
  name        = "service-b-sqs-policy"
  description = "Allow Service B to consume messages from SQS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
      Resource  = var.sqs_queue_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "service_b_sqs_policy_attach" {
  role       = aws_iam_role.service_b_task_role.name
  policy_arn = aws_iam_policy.service_b_sqs_policy.arn
}
