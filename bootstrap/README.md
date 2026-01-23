# Terraform Backend Bootstrap

This directory contains the Terraform configuration for creating the remote backend infrastructure (S3 bucket and DynamoDB table) used to store Terraform state.

## Resources Created

- **S3 Bucket**: `{prefix}-terraform-state`
  - Versioning enabled
  - AES256 encryption
  - Public access blocked
  - Lifecycle rule to expire old versions after 90 days

- **DynamoDB Table**: `{prefix}-terraform-state-lock`
  - PAY_PER_REQUEST billing mode
  - Point-in-time recovery enabled

## Usage

### Initial Setup

```bash
cd bootstrap
terraform init
terraform plan
terraform apply
```

### Migrate Main Configuration

After creating the backend resources:

```bash
cd ..
terraform init -migrate-state
```

## Notes

- These resources have `prevent_destroy` lifecycle rules
- Do NOT destroy this configuration while state files are stored in S3
- The bootstrap state is stored locally

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.28 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.terraform_state_lock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_s3_bucket.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_public_access_block.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for resource names | `string` | `"devops-demo-316330059714"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region for backend resources | `string` | `"ap-southeast-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_config"></a> [backend\_config](#output\_backend\_config) | Backend configuration for versions.tf |
| <a name="output_dynamodb_table_arn"></a> [dynamodb\_table\_arn](#output\_dynamodb\_table\_arn) | ARN of the DynamoDB table for state locking |
| <a name="output_dynamodb_table_name"></a> [dynamodb\_table\_name](#output\_dynamodb\_table\_name) | Name of the DynamoDB table for state locking |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | ARN of the S3 bucket for Terraform state |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | Name of the S3 bucket for Terraform state |
<!-- END_TF_DOCS -->
