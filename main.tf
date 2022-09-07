terraform {
  required_version = ">= 1.2.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.29.0"
    }

    github = {
      source  = "integrations/github"
      version = "4.31.0"
    }
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "github_repository" "source" {
  name = var.repo
}

locals {
  runtimes = {
    node = {
      action          = "actions/setup-node@v3"
      version_key     = "node-version"
      version_value   = var.node_version
      build_command   = "npm clean-install"
      lambda_runtime  = "nodejs${var.node_version}.x"
      default_handler = "index.handler"
    }

    python = {
      action          = "actions/setup-python@v4"
      version_key     = "python-version"
      version_value   = var.python_version
      build_command   = "pip install -r requirements.txt"
      lambda_runtime  = "python${var.python_version}"
      default_handler = "lambda_function.lambda_handler"
    }
  }

  description = length(var.description) > 0 ? var.description : data.github_repository.source.description
  handler     = length(var.handler) > 0 ? var.handler : local.runtimes[var.runtime].default_handler
}

resource "github_repository_file" "workflow_file" {
  repository = data.github_repository.source.name
  file       = ".github/workflows/build-and-deploy-${data.aws_caller_identity.current.account_id}.yml"
  content = templatefile("${path.module}/workflow-template.yml", {
    branch              = var.branch
    aws_account         = data.aws_caller_identity.current.account_id
    cicd_role           = var.cicd_role
    aws_region          = data.aws_region.current.name
    build_setup_action  = local.runtimes[var.runtime].action
    build_version_key   = local.runtimes[var.runtime].version_key
    build_version_value = local.runtimes[var.runtime].version_value
    build_command       = local.runtimes[var.runtime].build_command
    bucket              = var.lambda_bucket
    function_name       = var.function_name
  })
  commit_message      = "Adding workflow file"
  overwrite_on_create = false

  lifecycle {
    ignore_changes = all
  }
}

data "archive_file" "base_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/${var.runtime}_example"
  output_path = "${path.module}/package.zip"
}

resource "aws_s3_object" "default_handler" {
  bucket = var.lambda_bucket
  key    = "${var.function_name}.zip"
  source = data.archive_file.base_lambda.output_path

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = var.function_name
  assume_role_policy = file("${path.module}/assume.json")
}

resource "aws_lambda_function" "lambda" {
  function_name = var.function_name
  s3_bucket     = aws_s3_object.default_handler.bucket
  s3_key        = aws_s3_object.default_handler.key
  description   = local.description
  handler       = local.handler
  runtime       = local.runtimes[var.runtime].lambda_runtime
  role          = aws_iam_role.lambda_role.arn
  architectures = [var.architecture]
  publish       = var.publish

  dynamic environment {
    for_each = length(keys(var.environment)) > 0 ? {"0": "0"} : {}
    content {
      variables = var.environment
    }
  }

  tags = {
    "GitHubRepo" : data.github_repository.source.full_name
  }
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_in_days
}

resource "aws_iam_policy" "logging" {
  name        = "lambda_logging_for_${var.function_name}"
  path        = "/"
  description = "IAM policy for logging from the ${var.function_name} lambda"

  policy = templatefile("${path.module}/cloudwatch-logging.json", {
    aws_account = data.aws_caller_identity.current.account_id
    aws_region  = data.aws_region.current.name
    log_group   = aws_cloudwatch_log_group.logs.name
  })
}
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.logging.arn
}
