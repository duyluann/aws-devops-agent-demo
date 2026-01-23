variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "devops-agent-demo-316330059714"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.prefix))
    error_message = "Prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "region" {
  description = "AWS region for backend resources"
  type        = string
  default     = "us-east-1"
}
