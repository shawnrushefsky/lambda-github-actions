terraform {
  required_version = ">= 1.2.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.29.0"
    }

    github = {
      source = "integrations/github"
      version = "4.31.0"
    }
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

