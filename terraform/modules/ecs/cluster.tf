# ECS cluster using Fargate
resource "aws_ecs_cluster" "main_cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Environment = var.environment
  }
}

# Attach Fargate as capacity provider
resource "aws_ecs_cluster_capacity_providers" "main_cluster_capacity" {
  cluster_name       = aws_ecs_cluster.main_cluster.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}

# ECS Tasks Security Group
resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-sg"
  description = "Allows traffic to ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 0
    to_port         = 65535
    security_groups = [var.alb_sg_id] # Allow traffic from ALB
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
