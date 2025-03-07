# Frontend Task Definition (Next.js)
resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-service"
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.frontend_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "frontend-container"
      image     = var.frontend_image
      essential = true
      portMappings = [{
        containerPort = 3000
        protocol      = "tcp"
      }]
    }
  ])
}

# Service A Task Definition (gRPC Backend)
resource "aws_ecs_task_definition" "service_a" {
  family                   = "service-a"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.service_a_task_role_arn

  container_definitions = jsonencode([
    {
      name  = "service-a"
      image = var.service_a_image
      essential = true
      portMappings = [{
        containerPort = 50051
        protocol      = "tcp"
      }]
      environment = [
        { name = "MONGO_URI", value = var.mongodb_uri }
      ]
    }
  ])
}

# Service B Task Definition (SQS Consumer)
resource "aws_ecs_task_definition" "service_b" {
  family                   = "service-b"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.service_b_task_role_arn

  container_definitions = jsonencode([
    {
      name  = "service-b"
      image = var.service_b_image
      essential = true
      environment = [
        { name = "SQS_QUEUE_URL", value = var.sqs_queue_url },
        { name = "MONGO_URI", value = var.mongodb_uri }
      ]
    }
  ])
}

