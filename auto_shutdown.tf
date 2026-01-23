# Auto-shutdown resources for ALB Health Check Demo
# Lambda function and EventBridge rule to stop instances after 2 hours
# Enabled by default for dev/qa, disabled for prod

# Archive the Lambda function code
data "archive_file" "auto_shutdown" {
  count = var.enable_auto_shutdown ? 1 : 0

  type        = "zip"
  source_file = "${path.module}/files/auto_shutdown.py"
  output_path = "${path.module}/files/auto_shutdown.zip"
}

# Lambda Function
#
# checkov:skip=CKV_AWS_116: DLQ not needed for demo Lambda
# checkov:skip=CKV_AWS_117: VPC not needed for EC2 API calls
# checkov:skip=CKV_AWS_173: Environment variables not sensitive
# checkov:skip=CKV_AWS_272: Code signing not needed for demo
resource "aws_lambda_function" "auto_shutdown" {
  count = var.enable_auto_shutdown ? 1 : 0

  function_name = "${local.name_prefix}-auto-shutdown"
  description   = "Stops EC2 instances after 2 hours to save costs"
  role          = aws_iam_role.lambda_auto_shutdown[0].arn
  handler       = "auto_shutdown.handler"
  runtime       = "python3.12"
  timeout       = 30
  memory_size   = 128

  filename         = data.archive_file.auto_shutdown[0].output_path
  source_code_hash = data.archive_file.auto_shutdown[0].output_base64sha256

  environment {
    variables = {
      INSTANCE_IDS = join(",", aws_instance.web[*].id)
    }
  }

  # checkov:skip=CKV_AWS_50: X-Ray tracing not needed for demo
  tracing_config {
    mode = "PassThrough"
  }

  tags = {
    Name = "${local.name_prefix}-auto-shutdown"
  }
}

# CloudWatch Log Group for Lambda
#
# checkov:skip=CKV_AWS_338: Short retention for demo logs
resource "aws_cloudwatch_log_group" "auto_shutdown" {
  count = var.enable_auto_shutdown ? 1 : 0

  name              = "/aws/lambda/${local.name_prefix}-auto-shutdown"
  retention_in_days = 7

  tags = {
    Name = "${local.name_prefix}-auto-shutdown-logs"
  }
}

# EventBridge Rule - Runs every 2 hours
resource "aws_cloudwatch_event_rule" "auto_shutdown" {
  count = var.enable_auto_shutdown ? 1 : 0

  name                = "${local.name_prefix}-auto-shutdown-rule"
  description         = "Stop EC2 instances after 2 hours to save costs"
  schedule_expression = "rate(2 hours)"
  state               = "ENABLED"

  tags = {
    Name = "${local.name_prefix}-auto-shutdown-rule"
  }
}

# EventBridge Target
resource "aws_cloudwatch_event_target" "auto_shutdown" {
  count = var.enable_auto_shutdown ? 1 : 0

  rule      = aws_cloudwatch_event_rule.auto_shutdown[0].name
  target_id = "auto-shutdown-lambda"
  arn       = aws_lambda_function.auto_shutdown[0].arn
}

# Lambda Permission for EventBridge
resource "aws_lambda_permission" "auto_shutdown" {
  count = var.enable_auto_shutdown ? 1 : 0

  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_shutdown[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.auto_shutdown[0].arn
}
