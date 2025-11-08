terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 bucket for testing pipelines
resource "aws_s3_bucket" "liatrio_demo_bucket" {
  bucket = "${var.project_name}-${var.environment}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-bucket"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Liatrio Demo - Pipeline Testing"
  }
}