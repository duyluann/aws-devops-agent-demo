# EC2 instances for ALB Health Check Demo
# Instances running Python web app with health check simulation

resource "aws_instance" "web" {
  count = var.instance_count

  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[count.index % length(aws_subnet.public)].id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name
  key_name               = var.key_pair_name != "" ? var.key_pair_name : null

  # IMDSv2 required for security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  # EBS root volume with encryption
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name = "${local.name_prefix}-instance-${count.index + 1}-root"
    }
  }

  # User data script
  user_data = base64encode(templatefile("${path.module}/templates/userdata.sh.tpl", {
    instance_name = "${local.name_prefix}-instance-${count.index + 1}"
    environment   = var.env
  }))

  user_data_replace_on_change = true

  # Ensure route table is associated before launching
  depends_on = [
    aws_route_table_association.public,
    aws_internet_gateway.main
  ]

  tags = {
    Name        = "${local.name_prefix}-instance-${count.index + 1}"
    Application = "demo-webapp"
  }
}
