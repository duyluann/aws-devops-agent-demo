# Application Load Balancer for ALB Health Check Demo
# ALB, target group, and HTTP listener

# Application Load Balancer
#
# checkov:skip=CKV_AWS_150: Deletion protection disabled for demo - needs easy cleanup
# checkov:skip=CKV_AWS_91: Access logging not enabled for demo - would require S3 bucket
# checkov:skip=CKV2_AWS_28: WAF not associated for demo simplicity
resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false
  drop_invalid_header_fields = true

  tags = {
    Name = "${local.name_prefix}-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "main" {
  name     = "${local.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  target_type = "instance"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/health"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }

  # Faster deregistration for demo purposes
  deregistration_delay = 30

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  tags = {
    Name = "${local.name_prefix}-tg"
  }
}

# Target Group Attachments
resource "aws_lb_target_group_attachment" "web" {
  count = var.instance_count

  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

# HTTP Listener
#
# checkov:skip=CKV_AWS_2: Using HTTP for demo simplicity - HTTPS would require certificate
# checkov:skip=CKV_AWS_103: TLS 1.2 not applicable - using HTTP for demo
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = {
    Name = "${local.name_prefix}-http-listener"
  }
}
