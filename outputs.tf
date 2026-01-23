# Outputs for ALB Health Check Demo

# Environment information
output "environment" {
  description = "The environment name"
  value       = var.env
}

output "region" {
  description = "The AWS region where resources are deployed"
  value       = var.region
}

output "resource_prefix" {
  description = "The prefix used for resource naming"
  value       = local.resource_prefix
}

# ALB outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_url" {
  description = "URL to access the application"
  value       = local.alb_url
}

output "health_check_url" {
  description = "URL to check health endpoint"
  value       = local.health_check_url
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

# Network outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

# EC2 outputs
output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.web[*].id
}

output "instance_private_ips" {
  description = "Private IP addresses of the EC2 instances"
  value       = aws_instance.web[*].private_ip
}

# Monitoring outputs
output "cloudwatch_alarms" {
  description = "Names of CloudWatch alarms (if monitoring enabled)"
  value = var.enable_monitoring ? [
    aws_cloudwatch_metric_alarm.unhealthy_hosts[0].alarm_name,
    aws_cloudwatch_metric_alarm.high_response_time[0].alarm_name,
    aws_cloudwatch_metric_alarm.http_5xx_errors[0].alarm_name
  ] : []
}

output "cloudwatch_alarm_names" {
  description = "Map of alarm types to alarm names for incident testing"
  value = var.enable_monitoring ? {
    unhealthy_hosts    = aws_cloudwatch_metric_alarm.unhealthy_hosts[0].alarm_name
    high_response_time = aws_cloudwatch_metric_alarm.high_response_time[0].alarm_name
    http_5xx_errors    = aws_cloudwatch_metric_alarm.http_5xx_errors[0].alarm_name
  } : {}
}

# Demo helper commands
output "trigger_failure_command" {
  description = "Command to trigger health check failure (run via SSM or SSH)"
  value       = "curl http://localhost/simulate/unhealthy"
}

output "restore_health_command" {
  description = "Command to restore healthy status"
  value       = "curl http://localhost/simulate/healthy"
}

output "environment_tag" {
  description = "Tag value to use in DevOps Agent Space for resource discovery"
  value       = var.env
}

# Auto-shutdown outputs
output "auto_shutdown_enabled" {
  description = "Whether auto-shutdown is enabled"
  value       = var.enable_auto_shutdown
}

output "auto_shutdown_lambda_arn" {
  description = "ARN of the auto-shutdown Lambda function (if enabled)"
  value       = var.enable_auto_shutdown ? aws_lambda_function.auto_shutdown[0].arn : null
}
