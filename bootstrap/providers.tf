provider "aws" {
  region = var.region

  default_tags {
    tags = {
      ManagedBy = "Terraform-Bootstrap"
      Purpose   = "State Management"
    }
  }
}
