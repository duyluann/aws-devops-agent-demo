variable "region" {
  description = "The region to deploy the resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "env" {
  description = "The environment to deploy the resources"
  type        = string
  default     = "dev"
}

variable "prefix" {
  description = "The prefix for all resource's names"
  type        = string
  default     = "dev"
}

# ALB Health Check Demo Variables

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type for the demo web servers"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 2

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 4
    error_message = "Instance count must be between 1 and 4."
  }
}

variable "key_pair_name" {
  description = "EC2 Key Pair name for SSH access (optional, leave empty to disable SSH key)"
  type        = string
  default     = ""
}

variable "enable_ssh_access" {
  description = "Enable SSH access to EC2 instances (requires ssh_allowed_cidrs)"
  type        = bool
  default     = false
}

variable "ssh_allowed_cidrs" {
  description = "List of CIDR blocks allowed to SSH to EC2 instances"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.ssh_allowed_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All values must be valid CIDR blocks."
  }
}

variable "enable_monitoring" {
  description = "Enable CloudWatch alarms for ALB and targets"
  type        = bool
  default     = true
}

variable "enable_auto_shutdown" {
  description = "Enable automatic shutdown of instances after 2 hours (cost savings for demo)"
  type        = bool
  default     = true
}
