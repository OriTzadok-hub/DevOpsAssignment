# Autoscaling for Frontend (CPU-based)
resource "aws_appautoscaling_target" "frontend_target" {
  max_capacity       = 5
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main_cluster.name}/${aws_ecs_service.frontend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "frontend_cpu_scaling" {
  name               = "frontend-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.frontend_target.resource_id
  scalable_dimension = aws_appautoscaling_target.frontend_target.scalable_dimension
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 50
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

# Autoscaling for Service A (Latency-based)
resource "aws_appautoscaling_target" "service_a_target" {
  max_capacity       = var.service_a_max_capacity
  min_capacity       = var.service_a_min_capacity
  resource_id        = "service/${aws_ecs_cluster.main_cluster.name}/${aws_ecs_service.service_a.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_cloudwatch_metric_alarm" "service_a_latency_high" {
  alarm_name          = "service-a-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ServiceAResponseTime" # Custom latency metric
  namespace           = "Custom/ServiceA"
  period              = 60
  statistic           = "Average"
  threshold           = var.service_a_latency_threshold
  alarm_description   = "Alarm when Service A response time exceeds threshold"
  alarm_actions       = [aws_appautoscaling_policy.service_a_scale_up.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.main_cluster.name
    ServiceName = aws_ecs_service.service_a.name
  }
}


resource "aws_appautoscaling_policy" "service_a_scale_up" {
  name               = "service-a-scale-up"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.service_a_target.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  policy_type        = "StepScaling"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown               = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = var.service_a_latency_threshold
      scaling_adjustment          = 1  # Number of tasks to add when the threshold is exceeded
    }
  }
}

# Autoscaling for Service B (SQS-based)
resource "aws_appautoscaling_target" "service_b_target" {
  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main_cluster.name}/${aws_ecs_service.service_b.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "service_b_sqs_scaling" {
  name               = "service-b-sqs-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.service_b_target.resource_id
  scalable_dimension = aws_appautoscaling_target.service_b_target.scalable_dimension
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "SQSQueueMessagesVisible"
      resource_label         = var.sqs_queue_arn
    }
    target_value       = 10
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}


