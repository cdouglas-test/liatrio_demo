terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Cloud Posse tfstate-backend module for remote state management
module "tfstate_backend" {
  source  = "cloudposse/tfstate-backend/aws"
  version = "~> 1.4"

  namespace   = var.project_name
  environment = var.environment
  stage       = var.environment
  name        = "tfstate"

  # S3 bucket configuration
  s3_bucket_name         = "${var.project_name}-${var.environment}-tfstate-${random_string.tfstate_suffix.result}"
  s3_replication_enabled = false
  force_destroy          = var.environment != "prod" ? true : false

  # DynamoDB table configuration
  dynamodb_table_name = "${var.project_name}-${var.environment}-tfstate-lock"
  dynamodb_enabled    = true

  # Security settings
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Purpose     = "Terraform State Backend"
    ManagedBy   = "Terraform"
  }
}

# Random string for tfstate backend uniqueness
resource "random_string" "tfstate_suffix" {
  length  = 8
  special = false
  upper   = false
}
