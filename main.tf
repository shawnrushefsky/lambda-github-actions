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

locals {
  runtimes = {
    node = {
      action         = "actions/setup-node@v3"
      version_key    = "node-version"
      version_value  = var.node_version
      build_command  = "npm clean-install"
      lambda_runtime = "node${var.node_version}"
    }

    python = {
      action         = "actions/setup-python@v4"
      version_key    = "python-version"
      version_value  = var.python_version
      build_command  = "pip install -r requirements.txt"
      lambda_runtime = "python${var.python_version}"
    }
  }
}

resource "github_repository_file" {
  repository = var.repo
  file       = ".github/workflows/build-and-deploy-${data.aws_caller_identity.current.account_id}"
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
  output_file = "${path.module}/package.zip"
}

resource "aws_s3_object" {
  bucket = var.lambda_bucket
  key    = "${var.function_name}.zip"
  source = data.archive_file.base_lambda.output_file

  lifecycle {
    ignore_changes = all
  }
}