# The bucket is created by infrastructure/bootstrap. Supply its name at init:
#   terraform init -backend-config="bucket=<bucket name>"
terraform {
  backend "s3" {
    key          = "liatrio-demo/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
