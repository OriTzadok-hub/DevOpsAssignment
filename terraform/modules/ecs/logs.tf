# CloudWatch Log Group for Service A
resource "aws_cloudwatch_log_group" "service_a" {
  name              = "/aws/ecs/service-a"
  retention_in_days = 30
}

# CloudWatch Metric Filter for Service A Response Time
resource "aws_cloudwatch_log_metric_filter" "service_a_response_time" {
  name           = "ServiceAResponseTimeFilter"
  pattern        = "{ $.response_time != null }"
  log_group_name = aws_cloudwatch_log_group.service_a.name

  metric_transformation {
    name      = "ServiceAResponseTime"
    namespace = "Custom/ServiceA"
    value     = "$.response_time"
    unit      = "Milliseconds"
  }
}

