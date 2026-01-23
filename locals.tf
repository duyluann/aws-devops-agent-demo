# Local values for resource naming and common configurations

locals {
  # Resource naming convention: {prefix}-{environment}-{resource-type}-{name}
  resource_prefix = var.prefix != "" ? "${var.prefix}-${var.env}" : var.env

  # Naming patterns - Use these for consistent resource names
  name_prefix = local.resource_prefix

  # Demo-specific URLs (computed after resources are created)
  alb_url          = "http://${aws_lb.main.dns_name}"
  health_check_url = "http://${aws_lb.main.dns_name}/health"
}
