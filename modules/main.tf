provider "aws" {
  region = var.region
}
# Define OpenSearch domain
resource "aws_opensearch_domain" "opensearch" {
  domain_name    = var.domain_name
  engine_version = var.engine_version

  vpc_options {
    subnet_ids = var.subnet_ids
  }

  cluster_config {
    instance_type             = var.instance_type
    dedicated_master_enabled = false
    instance_count           = var.worker_nodes + var.master_nodes
  }

  ebs_options {
    ebs_enabled = true
    volume_type = var.volume_type 
    volume_size = var.volume_size    
  }

  tags = var.tags
}

# Define CloudWatch Alarm for CPU Utilization
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
  alarm_name          = "OpenSearchWorkerNodesCPUAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/OpenSearch"
  period              = 300  # 5 minutes period
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm triggered when worker nodes CPU utilization exceeds 80%"
  actions_enabled     = true
  dimensions = {
    DomainName = aws_opensearch_domain.opensearch.domain_name
    NodeRole   = "data"
  }

  alarm_actions = [aws_lambda_function.lambda_function.arn]
}

# Define Lambda function to send Slack notification
resource "aws_lambda_function" "lambda_function" {
  filename      = "./lambda_function.zip"
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }
}

# Define IAM Role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# Attach policies to IAM role for Lambda function
resource "aws_iam_role_policy_attachment" "lambda_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Define Lambda permission to allow CloudWatch to invoke Lambda function
resource "aws_lambda_permission" "cloudwatch_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_metric_alarm.cpu_utilization_alarm.arn
}
