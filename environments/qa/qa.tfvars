# QA/Staging Environment Configuration
# Production-like settings with cost optimizations

env    = "qa"
region = "ap-southeast-1"
prefix = "devops-demo"

# Network
vpc_cidr = "10.1.0.0/16"

# EC2 Instances - same as dev for demo
instance_type  = "t3.micro"
instance_count = 2

# SSH Access - disabled by default for security
enable_ssh_access = false
ssh_allowed_cidrs = []
key_pair_name     = ""

# Monitoring - enabled for testing
enable_monitoring = true

# Auto-shutdown - enabled to save costs (stops instances every 2 hours)
enable_auto_shutdown = true
