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

# ECR outputs
output "ecr_repository_url" {
  description = "ECR repository URL for container images"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.app_repo.name
}

# EKS outputs
output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_version" {
  description = "EKS cluster Kubernetes version"
  value       = module.eks.cluster_version
}

output "eks_oidc_provider_arn" {
  description = "EKS OIDC provider ARN"
  value       = module.eks.oidc_provider_arn
}

# VPC outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

# Utility outputs
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name}"
}