# Development Environment Configuration
# Cost-optimized settings for development and testing

env    = "dev"
region = "us-east-1"
prefix = "devops-demo"

# Network
vpc_cidr = "10.0.0.0/16"

# EC2 Instances - minimal for dev
instance_type  = "t3.micro"
instance_count = 2

# SSH Access - disabled by default for security
enable_ssh_access = false
ssh_allowed_cidrs = []
key_pair_name     = ""

# Monitoring - enabled to test alarms
enable_monitoring = true

# Auto-shutdown - disabled to keep instances running
enable_auto_shutdown = false
