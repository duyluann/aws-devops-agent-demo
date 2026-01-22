# Production Environment Configuration
# Full features enabled, no auto-shutdown

env    = "prod"
region = "ap-southeast-1"
prefix = "devops-demo"

# Network
vpc_cidr = "10.2.0.0/16"

# EC2 Instances - same size for demo consistency
instance_type  = "t3.micro"
instance_count = 2

# SSH Access - disabled by default for security
enable_ssh_access = false
ssh_allowed_cidrs = []
key_pair_name     = ""

# Monitoring - enabled for production visibility
enable_monitoring = true

# Auto-shutdown - DISABLED for production (instances stay running)
enable_auto_shutdown = false
