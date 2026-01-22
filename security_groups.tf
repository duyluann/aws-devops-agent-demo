# Security groups for ALB Health Check Demo
# Separate security groups for ALB and EC2 instances

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-alb-sg"
  }
}

# ALB ingress rule - HTTP from anywhere
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP traffic from anywhere"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "${local.name_prefix}-alb-http-ingress"
  }
}

# ALB egress rule - All traffic to VPC
resource "aws_vpc_security_group_egress_rule" "alb_to_ec2" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow all traffic to EC2 instances"
  ip_protocol       = "-1"
  cidr_ipv4         = var.vpc_cidr

  tags = {
    Name = "${local.name_prefix}-alb-egress"
  }
}

# EC2 Security Group
resource "aws_security_group" "ec2" {
  name        = "${local.name_prefix}-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-ec2-sg"
  }
}

# EC2 ingress rule - HTTP from ALB only
resource "aws_vpc_security_group_ingress_rule" "ec2_http_from_alb" {
  security_group_id            = aws_security_group.ec2.id
  description                  = "Allow HTTP traffic from ALB"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.alb.id

  tags = {
    Name = "${local.name_prefix}-ec2-http-from-alb"
  }
}

# EC2 ingress rule - SSH (optional, disabled by default)
resource "aws_vpc_security_group_ingress_rule" "ec2_ssh" {
  count = var.enable_ssh_access && length(var.ssh_allowed_cidrs) > 0 ? length(var.ssh_allowed_cidrs) : 0

  security_group_id = aws_security_group.ec2.id
  description       = "Allow SSH access from specified CIDR"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.ssh_allowed_cidrs[count.index]

  tags = {
    Name = "${local.name_prefix}-ec2-ssh-${count.index}"
  }
}

# EC2 egress rule - All traffic (required for yum updates, SSM, etc.)
resource "aws_vpc_security_group_egress_rule" "ec2_all" {
  security_group_id = aws_security_group.ec2.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "${local.name_prefix}-ec2-egress"
  }
}
