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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get current AWS account info
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
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
  dynamodb_table_name = "${var.project_name}-${var.environment}-tfstate-lock-${random_string.tfstate_suffix.result}"
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
    Demo        = "liatrio-demo"
  }
}

# Random string for tfstate backend uniqueness
resource "random_string" "tfstate_suffix" {
  length  = 8
  special = false
  upper   = false

  lifecycle {
    ignore_changes = all
  }
}

# ECR Repository for container images
resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.project_name}-${var.environment}-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-api"
    Project     = var.project_name
    Environment = var.environment
    Purpose     = "Container Registry"
    ManagedBy   = "Terraform"
    Demo        = "liatrio-demo"
  }
}

# ECR Repository Policy
resource "aws_ecr_repository_policy" "app_repo_policy" {
  repository = aws_ecr_repository.app_repo.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPull"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
      }
    ]
  })
}

# VPC for EKS cluster
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = slice(var.private_subnet_cidrs, 0, 2)
  public_subnets  = slice(var.public_subnet_cidrs, 0, 2)

  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tags required for EKS
  tags = {
    Name                                                                                                      = "${var.project_name}-${var.environment}-vpc"
    Project                                                                                                   = var.project_name
    Environment                                                                                               = var.environment
    ManagedBy                                                                                                 = "Terraform"
    Demo                                                                                                      = "liatrio-demo1"
    "kubernetes.io/cluster/${var.project_name}-${var.environment}-eks-${random_string.tfstate_suffix.result}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.project_name}-${var.environment}-eks-${random_string.tfstate_suffix.result}" = "shared"
    "kubernetes.io/role/elb"                                                                                  = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.project_name}-${var.environment}-eks-${random_string.tfstate_suffix.result}" = "shared"
    "kubernetes.io/role/internal-elb"                                                                         = 1
  }
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-${var.environment}-eks-${random_string.tfstate_suffix.result}"
  cluster_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Cluster endpoint configuration
  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  cluster_addons = {
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    main = {
      name           = "${var.project_name}-${var.environment}-nodes"
      instance_types = var.node_instance_types

      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      disk_size = 50

      labels = {
        Environment = var.environment
        Project     = var.project_name
      }

      tags = {
        Name        = "${var.project_name}-${var.environment}-node"
        Project     = var.project_name
        Environment = var.environment
        ManagedBy   = "Terraform"
        Demo        = "liatrio-demo"
      }

      # Increase timeouts for node group operations
      timeouts = {
        create = "30m"
        update = "30m"
        delete = "30m"
      }
    }
  }

  # Cluster access entry
  access_entries = merge({
    admin = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    }, var.github_actions_role_arn != "" ? {
    github_actions = {
      kubernetes_groups = []
      principal_arn     = var.github_actions_role_arn

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  } : {})

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Demo        = "liatrio-demo"
  }

  # Cluster-level timeouts
  cluster_timeouts = {
    create = "30m"
    update = "60m"
    delete = "15m"
  }
}

# Configure providers after EKS cluster creation
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
    }
  }
}