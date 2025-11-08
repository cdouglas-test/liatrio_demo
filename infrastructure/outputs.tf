output "s3_bucket_name" {
  description = "Name of the S3 bucket created"
  value       = aws_s3_bucket.liatrio_demo_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket created"
  value       = aws_s3_bucket.liatrio_demo_bucket.arn
}

output "s3_bucket_region" {
  description = "Region where the S3 bucket is created"
  value       = aws_s3_bucket.liatrio_demo_bucket.region
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.liatrio_demo_bucket.bucket_domain_name
}

output "test_object_key" {
  description = "Key of the test object in the S3 bucket"
  value       = aws_s3_object.test_object.key
}

output "test_object_etag" {
  description = "ETag of the test object"
  value       = aws_s3_object.test_object.etag
}

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