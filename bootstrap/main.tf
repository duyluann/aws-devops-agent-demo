#--------------------------------------------------------------
# Terraform Remote Backend Infrastructure
# S3 bucket for state storage and DynamoDB table for locking
#--------------------------------------------------------------

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.prefix}-terraform-state"

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name    = "${var.prefix}-terraform-state"
    Purpose = "Terraform State Storage"
  }
}

# Enable versioning for state history and recovery
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption (AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle rule to clean up old state versions
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "cleanup-old-state-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

#--------------------------------------------------------------
# DynamoDB Table for State Locking
#--------------------------------------------------------------

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "${var.prefix}-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = false
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name    = "${var.prefix}-terraform-state-lock"
    Purpose = "Terraform State Locking"
  }
}
