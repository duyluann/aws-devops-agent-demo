terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
  }

  # AWS S3 backend for team collaboration
  backend "s3" {
    bucket         = "devops-agent-demo-316330059714-terraform-state"
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "devops-agent-demo-316330059714-terraform-state-lock"
    encrypt        = true
  }
}
