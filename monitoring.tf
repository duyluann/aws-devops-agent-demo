# CloudWatch Alarms for ALB Health Check Demo
# Monitors unhealthy hosts, response time, and 5xx errors

# Unhealthy Hosts Alarm
resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  count = var.enable_monitoring ? 1 : 0

  alarm_name          = "${local.name_prefix}-unhealthy-hosts"
  alarm_description   = "Alarm when targets become unhealthy in the ALB target group"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    TargetGroup  = aws_lb_target_group.main.arn_suffix
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = {
    Name = "${local.name_prefix}-unhealthy-hosts-alarm"
  }
}

# Target Response Time Alarm
resource "aws_cloudwatch_metric_alarm" "high_response_time" {
  count = var.enable_monitoring ? 1 : 0

  alarm_name          = "${local.name_prefix}-high-response-time"
  alarm_description   = "Alarm when target response time is too high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 2
  treat_missing_data  = "notBreaching"

  dimensions = {
    TargetGroup  = aws_lb_target_group.main.arn_suffix
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = {
    Name = "${local.name_prefix}-high-response-time-alarm"
  }
}

# HTTP 5xx Errors Alarm
resource "aws_cloudwatch_metric_alarm" "http_5xx_errors" {
  count = var.enable_monitoring ? 1 : 0

  alarm_name          = "${local.name_prefix}-5xx-errors"
  alarm_description   = "Alarm when there are too many 5xx errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  treat_missing_data  = "notBreaching"

  dimensions = {
    TargetGroup  = aws_lb_target_group.main.arn_suffix
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = {
    Name = "${local.name_prefix}-5xx-errors-alarm"
  }
}
