terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
  region = "us-east-1"
  access_key = "AKIA6PKYBUIA2J3DUEEN"
  secret_key = "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"
}

resource "aws_lambda_function" "update_weight" {
    filename = "${path.module}/functions/update_weight.zip"
    function_name = "update_weight"
    handler = "update_weight.handler"
    role = aws_iam_role.update_weight_role.arn
    runtime = var.lambda_runtime
    depends_on = [aws_iam_role_policy_attachment.attach_iam_role_to_policy_update_weights]
    timeout = 300
}

resource "aws_lambda_function" "calculate_weights" {
    filename = "${path.module}/functions/calculate_weights.zip"
    function_name = "calculate_weights"
    handler = "calculate_weights.handler"
    role = aws_iam_role.update_weight_role.arn
    runtime = var.lambda_runtime
    depends_on = [aws_iam_role_policy_attachment.attach_iam_role_to_policy_calc_weights]
    timeout = 300
}

resource "aws_lambda_function" "finalize" {
    filename = "${path.module}/functions/finalize.zip"
    function_name = "finalize"
    handler = "finalize.handler"
    role = aws_iam_role.finalize_role.arn
    runtime = var.lambda_runtime
    depends_on = [aws_iam_role_policy_attachment.attach_iam_role_to_policy_finalize]
    timeout = 300
}

resource "aws_lambda_function" "threshold_check" {
    filename = "${path.module}/functions/threshold_check.zip"
    function_name = "threshold_check"
    handler = "threshold_check.handler"
    role = aws_iam_role.usage_role.arn
    runtime = var.lambda_runtime
    depends_on = [aws_iam_role_policy_attachment.attach_iam_role_to_policy_usage]
    timeout = 300
}

resource "aws_lambda_function" "rollback" {
    filename = "${path.module}/functions/rollback.zip"
    function_name = "rollback"
    handler = "rollback.handler"
    role = aws_iam_role.rollback_role.arn
    runtime = var.lambda_runtime
    depends_on = [aws_iam_role_policy_attachment.attach_iam_role_to_policy_rollback]
    timeout = 300
}

resource "aws_lambda_function" "simple" {
    filename = "${path.module}/functions/simple.zip"
    function_name = "simple"
    handler = "simple.handler"
    role = aws_iam_role.simple_role.arn
    runtime = var.lambda_runtime
    depends_on = [aws_iam_role_policy_attachment.attach_iam_role_to_policy_simple]
    timeout = 300
}

resource "aws_lambda_function" "health_check" {
    filename = "${path.module}/functions/health_check.zip"
    function_name = "health_check"
    handler = "health_check.handler"
    role = aws_iam_role.healthcheck_role.arn
    runtime = var.lambda_runtime
    depends_on = [aws_iam_role_policy_attachment.attach_iam_role_to_policy_healthcheck]
    timeout = 300
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "test_policy_for_lambda"
  path        = "/"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudformation:DescribeStacks",
          "cloudformation:ListStackResources",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "kms:ListAliases",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:ListRoles",
          "lambda:*",
          "logs:DescribeLogGroups",
          "states:DescribeStateMachine",
          "states:ListStateMachines",
          "autoscaling:Describe*",
          "cloudwatch:*",
          "logs:*",
          "sns:*",
  
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
resource "aws_iam_policy" "state_machine_policy" {
  name        = "test_policy_for_state_machine"
  path        = "/"
  description = "state machine policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [ 
            "lambda:InvokeFunction"
        ]
        Effect = "Allow"
        Resource = "*"
    }
    ]
  })
}

resource "aws_iam_role" "usage_role" {
    name = "check_usage_role"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "calculate_weights_role" {
    name = "calculate_weights_role"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.us-east-1.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "finalize_role" {
    name = "finalize_role"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "healthcheck_role" {
    name = "healthcheck_role"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "rollback_role" {
    name = "rollback_role"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "update_weight_role" {
    name = "update_weights_role"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "simple_role" {
    name = "simple_role"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "state_machine_execution_role" {
    name = "state_machine_execution_role"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "attach_iam_role_to_policy_calc_weights" {
  role       = aws_iam_role.calculate_weights_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
resource "aws_iam_role_policy_attachment" "attach_iam_role_to_policy_update_weights" {
  role       = aws_iam_role.update_weight_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
resource "aws_iam_role_policy_attachment" "attach_iam_role_to_policy_finalize" {
  role       = aws_iam_role.finalize_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
resource "aws_iam_role_policy_attachment" "attach_iam_role_to_policy_usage" {
  role       = aws_iam_role.usage_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
resource "aws_iam_role_policy_attachment" "attach_iam_role_to_policy_rollback" {
  role       = aws_iam_role.rollback_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
resource "aws_iam_role_policy_attachment" "attach_iam_role_to_policy_simple" {
  role       = aws_iam_role.simple_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
resource "aws_iam_role_policy_attachment" "attach_iam_role_to_policy_healthcheck" {
  role       = aws_iam_role.healthcheck_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
resource "aws_iam_role_policy_attachment" "attach_iam_role_to_policy_state_machine" {
  role       = aws_iam_role.state_machine_execution_role.name
  policy_arn = aws_iam_policy.state_machine_policy.arn
}

data "archive_file" "zip_fin" {
  type = "zip"
  source_dir = "${path.module}/functions/fin"
  output_path = "${path.module}/functions/finalize.zip"
}
data "archive_file" "zip_update" {
  type = "zip"
  source_dir = "${path.module}/functions/calc_weights"
  output_path = "${path.module}/functions/calculate_weights.zip"
}
data "archive_file" "zip_hc" {
  type = "zip"
  source_dir = "${path.module}/functions/hc"
  output_path = "${path.module}/functions/health_check.zip"
}
data "archive_file" "zip_roll" {
  type = "zip"
  source_dir = "${path.module}/functions/rollback"
  output_path = "${path.module}/functions/rollback.zip"
}
data "archive_file" "zip_simple" {
  type = "zip"
  source_dir = "${path.module}/functions/simp"
  output_path = "${path.module}/functions/simple.zip"
}
data "archive_file" "zip_thresh" {
  type = "zip"
  source_dir = "${path.module}/functions/thresh"
  output_path = "${path.module}/functions/threshold_check.zip"
}
data "archive_file" "zip_udpate" {
  type = "zip"
  source_dir = "${path.module}/functions/update"
  output_path = "${path.module}/functions/update_weight.zip"
}


resource "aws_sfn_state_machine" "StepFunctionsStateMachine" {
    name = "CanaryStateMachine"
    definition = <<EOF
{
  "Comment": "A state machine that deploys a Lambda function incrementally using a Weighted Alias",
  "StartAt": "CalculateWeights",
  "States": {
    "CalculateWeights": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.calculate_weights.arn}",
      "ResultPath": "$.weights",
      "Next": "UpdateWeight"
    },
    "UpdateWeight": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.update_weight.arn}",
      "ResultPath": "$.current-weight",
      "Next": "Wait"
    },
    "Wait": {
      "Type": "Wait",
      "SecondsPath": "$.interval",
      "Next": "Usage Check"
    },
    "Usage Check": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.threshold_check.arn}",
      "ResultPath": "$.usage",
      "Next": "Choice"
    },
    "Choice": {
      "Type": "Choice",
      "Choices": [
        {
          "Not": {
            "Variable": "$.usage",
            "StringEquals": "FULL"
          },
          "Next": "Wait"
        }
      ],
      "Default": "HealthCheck"
    },
    "HealthCheck": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.health_check.arn}",
      "Next": "VerifyHealthCheck",
      "InputPath": "$",
      "ResultPath": "$.status"
    },
    "VerifyHealthCheck": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.status",
          "StringEquals": "FAILED",
          "Next": "Rollback"
        },
        {
          "Variable": "$.status",
          "StringEquals": "SUCCEEDED",
          "Next": "IsFullyWeighted"
        }
      ],
      "Default": "Rollback"
    },
    "IsFullyWeighted": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.current-weight",
          "NumericEquals": 1,
          "Next": "Finalize"
        }
      ],
      "Default": "UpdateWeight"
    },
    "Rollback": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.rollback.arn}",
      "Next": "Fail",
      "InputPath": "$",
      "ResultPath": "$"
    },
    "Fail": {
      "Type": "Fail",
      "Cause": "Function deployment failed",
      "Error": "HealthCheck returned FAILED"
    },
    "Finalize": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.finalize.arn}",
      "InputPath": "$",
      "End": true
    }
  }
}
EOF
    role_arn = aws_iam_role.state_machine_execution_role.arn
}


