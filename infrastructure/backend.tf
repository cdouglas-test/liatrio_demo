# backend.tf
# Remote state backend configuration

terraform {
  backend "s3" {
    bucket         = "liatrio-demo-dev-tfstate-u58x74nr"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "liatrio-demo-dev-tfstate-lock"
    encrypt        = true
  }
}
