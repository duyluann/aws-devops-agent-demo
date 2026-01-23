# 🚧 Terraform Project Template

This repository provides a structured template for Terraform projects, enabling consistent and scalable infrastructure deployments. The template has best practices, CI/CD integration, and environment-specific configurations to streamline infrastructure management.

## 📁 Repository Structure

```bash
.
├── backend.tf                          # 🔧 Defines the backend configuration for Terraform
├── CHANGELOG.md                        # 📝 Change log of the project
├── .checkov.yml                        # 🔒 Configuration file for Checkov security scanner
├── CODEOWNERS                          # 👥 Defines the code owners for the repository
├── .devcontainer                       # 🐳 Development container configuration
│   ├── devcontainer.json               # 📦 Devcontainer configuration file
│   └── Dockerfile                      # 🐋 Dockerfile for the dev environment
├── .editorconfig                       # 🖊️ Configuration for consistent coding styles
├── environments                        # 🌍 Holds environment-specific variables
│   ├── dev
│   │   └── dev.tfvars                  # 🛠️ Development environment variables
│   ├── prod
│   │   └── prod.tfvars                 # 🚀 Production environment variables
│   └── qa
│       └── qa.tfvars                   # 🔍 QA environment variables
├── .github                             # 🛠️ GitHub-specific configurations
│   ├── dependabot.yml                  # 🤖 Dependabot configuration
│   ├── ISSUE_TEMPLATE                  # 📝 GitHub issue template
│   │   └── issue_template.md           # 📝 Issue template file
│   ├── pull_request_template.md        # 📝 Pull request template
│   └── workflows                       # ⚙️ GitHub Actions workflows
│       ├── lint-pr.yaml                # 🧹 Linting workflow for pull requests
│       ├── pre-commit-auto-update.yaml # 🔄 Pre-commit hook auto-update workflow
│       ├── release.yaml                # 🚀 Release workflow
│       ├── stale.yaml                  # ⏳ Stale issue management workflow
│       ├── template-repo-sync.yaml     # 🔄 Template repository sync workflow
│       └── terraform-aws.yml           # ☁️ Terraform AWS workflow
├── .gitignore                          # 🚫 Files and directories to be ignored by Git
├── LICENSE                             # ⚖️ License for the project
├── locals.tf                           # 🛠️ Local variables for Terraform
├── main.tf                             # 🌐 Main Terraform configuration
├── modules                             # 📦 Custom Terraform modules
│   └── s3-bucket
│       ├── main.tf                     # 🌐 Main configuration for s3-bucket
│       ├── outputs.tf                  # 📤 Output definitions for s3-bucket
│       └── variables.tf                # 📥 Input variables for s3-bucket
├── .pre-commit-config.yaml             # 🛠️ Pre-commit hooks configuration
├── providers.tf                        # ☁️ Provider configurations for Terraform
├── README.md                           # 📖 Project documentation (this file)
├── .releaserc.json                     # 🚀 Semantic release configuration
├── .terraform.lock.hcl                 # 🔒 Terraform lock file
├── .tflint.hcl                         # 🛠️ Terraform linting configuration
├── variables.tf                        # 📥 Input variables for the project
└── .vscode                             # 🖥️ VSCode-specific configurations
    └── extensions.json                 # 🛠️ Recommended extensions for VSCode
```

## 🚀 Getting Started

### 🧰 Prerequisites

- Terraform: Ensure you have Terraform installed.
- Docker: Required for the development container setup.
- VSCode: Recommended for development, with the Dev Containers extension.

### 🖥️ Development Environment

To get started with development, you can use the pre-configured development container:

1. Open in VSCode:

- Install the Dev Containers extension.
- Open the repository in VSCode.
- You should see a prompt to reopen the project in the dev container.

2. Build and Run:

- The dev container is pre-configured with all the necessary tools and extensions.
- You can start writing and testing your Terraform configurations immediately.

### 🛠️ Terraform Configuration

- Backend Configuration: The `backend.tf` file configures the remote state storage for Terraform.
- Environment Variables: The `environments/` directory contains environment-specific variable files (`.tfvars`).
- Modules: Reusable Terraform modules are stored in the `modules/` directory.

### ✅ Pre-Commit Hooks

Pre-commit hooks are set up to ensure code quality and consistency. To install the pre-commit hooks:

```bash
pre-commit install
```

## ⚙️ Semantic Commit Messages
This project uses [Semantic Commit Messages](https://www.conventionalcommits.org/) to ensure meaningful and consistent commit history. The format is as follows:

```php
<type>(<scope>): <subject>
```

### Types

- `feat`: A new feature (e.g., `feat: add login functionality`).
- `fix`: A bug fix (e.g., `fix: resolve login button issue`).
- `docs`: Documentation changes (e.g., `docs: update API documentation`).
- `style`: Code style changes (formatting, missing semi-colons, etc.) without changing logic (e.g., `style: fix indentation`).
- `refactor`: Code changes that neither fix a bug nor add a feature (e.g., `refactor: update user controller structure`).
- `test`: Adding or updating tests (e.g., `test: add unit tests for login service`).
- `chore`: Changes to build process, auxiliary tools, or libraries (e.g., `chore: update dependencies`).

### Scope

Optional: The part of the codebase affected by the change (e.g., `feat(auth): add OAuth support`)

### Subject

A brief description of the change, using the imperative mood (e.g., `fix: resolve issue with user authentication`).

## 🚀 Semantic Release

This project is configured with [Semantic Release](https://semantic-release.gitbook.io/semantic-release) to automate the release process based on your commit messages.

### How It Works

1. Analyze commits: Semantic Release inspects commit messages to determine the type of changes in the codebase.
2. Generate release version: Based on the commit type, it will automatically bump the version following semantic versioning:
- fix → Patch release (e.g., 1.0.1)
- feat → Minor release (e.g., 1.1.0)
- BREAKING CHANGE → Major release (e.g., 2.0.0)
3. Create release notes: It generates a changelog from the commit messages and includes it in the release.
4. Publish: It automatically publishes the new version to the repository (and any other configured registries, e.g., npm).

## 🤝 Contributing

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Submit a pull request with a detailed description of the changes.

## 📜 License

This project is licensed under the [MIT License](LICENSE).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.28 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.7.1 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.auto_shutdown](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.auto_shutdown](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.auto_shutdown](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.high_response_time](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.http_5xx_errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.unhealthy_hosts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_instance_profile.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.lambda_auto_shutdown](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.lambda_ec2_stop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ec2_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ec2_ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_basic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_lambda_function.auto_shutdown](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.auto_shutdown](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_route.public_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_security_group_egress_rule.alb_to_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.ec2_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.alb_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ec2_http_from_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ec2_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [archive_file.auto_shutdown](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_ami.amazon_linux_2023](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_auto_shutdown"></a> [enable\_auto\_shutdown](#input\_enable\_auto\_shutdown) | Enable automatic shutdown of instances after 2 hours (cost savings for demo) | `bool` | `true` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enable CloudWatch alarms for ALB and targets | `bool` | `true` | no |
| <a name="input_enable_ssh_access"></a> [enable\_ssh\_access](#input\_enable\_ssh\_access) | Enable SSH access to EC2 instances (requires ssh\_allowed\_cidrs) | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | The environment to deploy the resources | `string` | `"dev"` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of EC2 instances to create | `number` | `2` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type for the demo web servers | `string` | `"t3.micro"` | no |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | EC2 Key Pair name for SSH access (optional, leave empty to disable SSH key) | `string` | `""` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix for all resource's names | `string` | `"dev"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to deploy the resources | `string` | `"ap-southeast-1"` | no |
| <a name="input_ssh_allowed_cidrs"></a> [ssh\_allowed\_cidrs](#input\_ssh\_allowed\_cidrs) | List of CIDR blocks allowed to SSH to EC2 instances | `list(string)` | `[]` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ARN of the Application Load Balancer |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS name of the Application Load Balancer |
| <a name="output_alb_url"></a> [alb\_url](#output\_alb\_url) | URL to access the application |
| <a name="output_auto_shutdown_enabled"></a> [auto\_shutdown\_enabled](#output\_auto\_shutdown\_enabled) | Whether auto-shutdown is enabled |
| <a name="output_auto_shutdown_lambda_arn"></a> [auto\_shutdown\_lambda\_arn](#output\_auto\_shutdown\_lambda\_arn) | ARN of the auto-shutdown Lambda function (if enabled) |
| <a name="output_cloudwatch_alarms"></a> [cloudwatch\_alarms](#output\_cloudwatch\_alarms) | Names of CloudWatch alarms (if monitoring enabled) |
| <a name="output_environment"></a> [environment](#output\_environment) | The environment name |
| <a name="output_environment_tag"></a> [environment\_tag](#output\_environment\_tag) | Tag value to use in DevOps Agent Space for resource discovery |
| <a name="output_health_check_url"></a> [health\_check\_url](#output\_health\_check\_url) | URL to check health endpoint |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | IDs of the EC2 instances |
| <a name="output_instance_private_ips"></a> [instance\_private\_ips](#output\_instance\_private\_ips) | Private IP addresses of the EC2 instances |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | IDs of the public subnets |
| <a name="output_region"></a> [region](#output\_region) | The AWS region where resources are deployed |
| <a name="output_resource_prefix"></a> [resource\_prefix](#output\_resource\_prefix) | The prefix used for resource naming |
| <a name="output_restore_health_command"></a> [restore\_health\_command](#output\_restore\_health\_command) | Command to restore healthy status |
| <a name="output_trigger_failure_command"></a> [trigger\_failure\_command](#output\_trigger\_failure\_command) | Command to trigger health check failure (run via SSM or SSH) |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC |
<!-- END_TF_DOCS -->
