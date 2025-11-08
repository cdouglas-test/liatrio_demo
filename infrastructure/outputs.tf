# Terraform state backend outputs
output "tfstate_backend_s3_bucket_id" {
  description = "S3 bucket ID for Terraform state"
  value       = module.tfstate_backend.s3_bucket_id
}

output "tfstate_backend_s3_bucket_arn" {
  description = "S3 bucket ARN for Terraform state"
  value       = module.tfstate_backend.s3_bucket_arn
}

output "tfstate_backend_dynamodb_table_id" {
  description = "DynamoDB table ID for state locking"
  value       = module.tfstate_backend.dynamodb_table_id
}

output "tfstate_backend_dynamodb_table_arn" {
  description = "DynamoDB table ARN for state locking"
  value       = module.tfstate_backend.dynamodb_table_arn
}

output "tfstate_backend_config" {
  description = "Terraform backend configuration block"
  value = {
    bucket         = module.tfstate_backend.s3_bucket_id
    key            = "terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = module.tfstate_backend.dynamodb_table_id
    encrypt        = true
  }
}