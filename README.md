# Liatrio Demo - Cloud-Native Flask API

Enterprise cloud-native Flask API demonstrating modern DevOps practices with Kubernetes deployment on AWS EKS, automated CI/CD pipelines, and Infrastructure as Code.

## 🚀 Overview

This project showcases a complete cloud-native deployment pipeline featuring:

- **Flask REST API** with production-ready endpoints
- **AWS EKS** Kubernetes cluster provisioned with Terraform
- **GitHub Actions** CI/CD pipeline with OIDC authentication
- **Docker** containerization with ECR registry
- **Infrastructure as Code** using Terraform modules
- **Automated testing** and deployment validation

### API Endpoints

- `GET /api` - Returns `{"message": "Automate all the things!", "timestamp": <unix_timestamp>}`
- `GET /health` - Health check endpoint for Kubernetes probes
- `GET /metrics` - Basic metrics and service information
- `GET /` - Welcome endpoint with API documentation

## 📋 Prerequisites

### Required Tools

- **AWS CLI** v2.x ([Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
- **Terraform** v1.0+ ([Installation Guide](https://developer.hashicorp.com/terraform/install))
- **kubectl** ([Installation Guide](https://kubernetes.io/docs/tasks/tools/))
- **Docker** ([Installation Guide](https://docs.docker.com/get-docker/))
- **PowerShell** 5.1+ or PowerShell Core 7+ (for manual deployment scripts)

### AWS Requirements

- AWS Account with appropriate permissions
- AWS CLI configured with credentials (`aws configure`)
- Permissions for: EKS, EC2, VPC, IAM, ECR, S3, DynamoDB

### Estimated Costs

- **EKS Cluster**: ~$0.10/hour ($73/month)
- **EC2 Nodes**: ~$0.05/hour per t3.medium instance
- **Total**: Under $100 for development/demo usage

## 🏗️ Architecture

```text
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│ GitHub Actions  │───▶│   AWS ECR       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Terraform     │───▶│   AWS EKS       │◀───│ Load Balancer   │
│   (IaC)         │    │   Cluster       │    │   Service       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Infrastructure Components

- **VPC** with public/private subnets across 2 AZs
- **EKS Cluster** with managed node groups
- **ECR Repository** for container images
- **S3 + DynamoDB** for Terraform state management
- **IAM Roles** with least-privilege access
- **Security Groups** for network access control

## 🚀 Quick Start Guide

### 1. Clone and Setup

```bash
git clone https://github.com/CRdouglas/liatrio_demo.git
cd liatrio_demo
```

### 2. Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID, Secret, Region (us-east-1), and output format (json)

# Verify configuration
aws sts get-caller-identity
```

### 3. Deploy Infrastructure

The infrastructure uses a remote Terraform state backend (S3 + DynamoDB) for state management. Follow these steps:

```bash
cd infrastructure

# Step 1: Initialize Terraform (local state initially)
terraform init

# Step 2: Deploy the state backend infrastructure first
terraform apply -target=module.tfstate_backend -target=random_string.tfstate_suffix

# Step 3: Configure remote backend (after S3 bucket is created)
# The backend configuration will be automatically set up
terraform init -migrate-state

# Step 4: Review full infrastructure plan
terraform plan

# Step 5: Deploy remaining infrastructure (takes ~15-20 minutes)
terraform apply
```

**Important Notes:**

- The first `terraform apply` creates the S3 bucket and DynamoDB table for state storage
- The `terraform init -migrate-state` migrates your local state to the remote backend
- Subsequent team members can skip steps 2-3 and run normal `init/plan/apply` for the same environment

### 4. Deploy Application

**Option A: Automated CI/CD**
1. Fork repository and set up `dev` environment in GitHub
2. Add `AWS_ROLE_ARN` variable: `arn:aws:iam::ACCOUNT:role/github-actions-role`
3. Create PRs with conventional titles (see PR Title Conventions below)
4. Automatic semantic versioning, releases, and deployment

### 5. Verify Deployment

```bash
# Check cluster status
kubectl get nodes

# Check application pods
kubectl get pods -l app=liatrio-demo-api-simple

# Get load balancer URL
kubectl get service liatrio-demo-api-simple-service

# Test API endpoint
curl http://<LOAD_BALANCER_URL>/api
```

## 👨‍💻 Developer Guide

### Local Development

#### Running Locally

```bash
cd app

# Install dependencies
pip install -r requirements.txt

# Run Flask development server
python app.py
```

The API will be available at `http://localhost:8080`

#### Testing Locally with Docker

```bash
cd app

# Build Docker image
docker build -t liatrio-demo-api .

# Run container
docker run -p 8080:8080 liatrio-demo-api

# Test endpoints
curl http://localhost:8080/api
curl http://localhost:8080/health
```

#### Local Testing

## PR Title Conventions & Automated Releases

This project uses **semantic versioning** with automated releases based on PR title conventions. Follow these PR title formats to trigger proper version bumps and releases when your PR is merged:

### PR Title Format
```
<type>: <description>

[optional scope in parentheses]
```

### PR Title Types
- **`feat:`** New features → **Minor version bump** (v1.1.0)
- **`fix:`** Bug fixes → **Patch version bump** (v1.0.1)  
- **`docs:`** Documentation changes → No version bump
- **`style:`** Code formatting → No version bump
- **`refactor:`** Code restructuring → No version bump
- **`test:`** Test additions/updates → No version bump
- **`chore:`** Maintenance tasks → No version bump
- **`BREAKING CHANGE:`** Breaking changes → **Major version bump** (v2.0.0)

### Examples
```bash
# Patch release (v1.0.1)
PR Title: "fix: resolve API timeout issue in health endpoint"

# Minor release (v1.1.0) 
PR Title: "feat: add new metrics endpoint for monitoring"

# Major release (v2.0.0)
PR Title: "feat!: update API to v2 format"
# OR
PR Title: "feat: update API with breaking changes"

# No release
PR Title: "docs: update README with deployment examples"

# With scope
PR Title: "feat(api): add user authentication system"
PR Title: "fix(auth): resolve login timeout issue"
```

### Commit Message Freedom
Within your PR, **commit messages can be flexible** - focus on clear development history:
```bash
# These commits are fine within a PR titled "feat: add user auth"
git commit -m "add login endpoint"
git commit -m "implement JWT validation"  
git commit -m "fix typo in error message"
git commit -m "add tests for auth flow"
```

### Automated Workflows
### Automated Workflows
- **Pull Requests:** PR title validation, build and test without deploying
- **Main Branch:** Full CI/CD pipeline with automatic versioning based on PR title
- **Release Creation:** Automatic GitHub releases with generated changelogs
- **Container Tagging:** Docker images tagged with semantic versions (v1.2.3)

The project includes a comprehensive automated test suite that validates all API endpoints and functionality.

**Quick Test Run:**

```bash
cd app

# Install test dependencies
pip install -r requirements.txt

# Run all tests
python -m pytest test_app.py -v

# Run tests with coverage report
python -m pytest test_app.py -v --cov=app --cov-report=term-missing
```

**Windows PowerShell:**

```powershell
Set-Location app

# Install dependencies
python -m pip install -r requirements.txt

# Run tests
python -m pytest test_app.py -v --cov=app --cov-report=term-missing

# Or use the test runner script
python run_tests.py
```

**Test Categories:**

- **Unit Tests** (`@pytest.mark.unit`) - Individual function testing
- **Integration Tests** (`@pytest.mark.integration`) - Component interaction testing  
- **Contract Tests** (`@pytest.mark.contract`) - API compliance with problem statement

**Run Specific Test Categories:**

```bash
# Run only unit tests
python -m pytest test_app.py -v -m unit

# Run only contract compliance tests
python -m pytest test_app.py -v -m contract

# Run only integration tests
python -m pytest test_app.py -v -m integration
```

**Current Test Coverage Summary:**

- ✅ **16 tests** covering all endpoints and functionality
- ✅ **88% code coverage** of the Flask application
- ✅ **Problem statement compliance** validation
- ✅ **Kubernetes readiness** endpoint testing
- ✅ **Error handling** and edge case validation

### Making Changes

#### Application Changes

1. **Modify code** in `app/` directory
2. **Test locally** using Flask development server
3. **Build and test** Docker image locally
4. **Commit changes** to trigger CI/CD pipeline
5. **Monitor deployment** in GitHub Actions

#### Infrastructure Changes

1. **Modify Terraform** configuration in `infrastructure/`
2. **Validate changes**: `terraform plan`
3. **Apply changes**: `terraform apply`
4. **Update Kubernetes manifests** if needed in `k8s/`

#### Kubernetes Configuration

1. **Modify manifests** in `k8s/` directory
2. **Test locally**: `kubectl apply -f k8s/simple-deployment.yaml`
3. **Commit changes** to trigger deployment

### Project Structure

```text
liatrio_demo/
├── app/                          # Flask application
│   ├── app.py                   # Main application file
│   ├── requirements.txt         # Python dependencies
│   └── Dockerfile              # Container configuration
├── infrastructure/              # Terraform IaC
│   ├── main.tf                 # Main infrastructure configuration
│   ├── variables.tf            # Variable definitions
│   ├── outputs.tf              # Output values
│   └── terraform.tfvars        # Environment variables
├── k8s/                        # Kubernetes manifests
│   ├── simple-deployment.yaml  # Main deployment (used by CI/CD)
│   └── deployment.yaml         # Alternative deployment with Ingress
├── .github/workflows/          # CI/CD pipeline
│   └── build-deploy.yml        # GitHub Actions workflow
├── scripts/                    # Deployment utilities
│   └── deploy.ps1              # Manual deployment script
└── README.md                   # This file
```

### Debugging Common Issues

#### Terraform State Backend Issues

```bash
# If state migration fails or backend issues occur:

# Check if S3 bucket exists
aws s3 ls | grep tfstate

# Check DynamoDB table
aws dynamodb list-tables | grep tfstate

# Reset to local state (emergency only)
rm -rf .terraform
terraform init -backend=false

# Re-run backend setup
terraform apply -target=module.tfstate_backend -target=random_string.tfstate_suffix
terraform init -migrate-state
```

#### Pod Won't Start

```bash
# Check pod status
kubectl get pods -l app=liatrio-demo-api-simple

# Get detailed pod information
kubectl describe pod <pod-name>

# Check application logs
kubectl logs <pod-name>
```

#### Memory Issues (OOMKilled)

The application was initially configured with 32Mi memory limits, which caused OOMKilled errors with Gunicorn's 2-worker configuration. Current allocation:

```yaml
resources:
  requests:
    memory: "128Mi"
  limits:
    memory: "256Mi"
```

#### Load Balancer Issues

```bash
# Check service status
kubectl get service liatrio-demo-api-simple-service

# Check load balancer provisioning
kubectl describe service liatrio-demo-api-simple-service
```

#### CI/CD Pipeline Failures

1. **Check GitHub Actions** logs in repository Actions tab
2. **Verify AWS permissions** for GitHub Actions role
3. **Check ECR repository** exists and is accessible
4. **Validate Kubernetes manifests** locally

### Testing Strategy

#### Automated Tests

- **Container build** validation in CI/CD
- **Deployment health checks** with readiness probes
- **API endpoint validation** after deployment
- **Infrastructure validation** with Terraform plan

#### Manual Testing

```bash
# API functionality
curl http://<LOAD_BALANCER_URL>/api
curl http://<LOAD_BALANCER_URL>/health

# Kubernetes resources
kubectl get all -l app=liatrio-demo-api-simple

# Infrastructure status
terraform plan  # Should show no changes
```

## 🔧 Advanced Configuration

### Multi-Environment Setup

To deploy to additional environments:

1. **Create new terraform.tfvars** file:

   ```hcl
   aws_region   = "us-east-1"
   project_name = "liatrio-demo"
   environment  = "staging"  # or "prod"
   ```

2. **Deploy with workspace**:

   ```bash
   terraform workspace new staging
   terraform apply -var-file="staging.tfvars"
   ```

### Scaling Configuration

Modify `infrastructure/terraform.tfvars`:

```hcl
node_group_min_size     = 2
node_group_max_size     = 10
node_group_desired_size = 3
node_instance_types     = ["t3.medium", "t3.large"]
```

### Security Enhancements

- **Pod Security Standards**: Implement PSS policies
- **Network Policies**: Restrict pod-to-pod communication
- **RBAC**: Configure role-based access control
- **Secrets Management**: Use AWS Secrets Manager or External Secrets Operator

## 🧹 Cleanup

### Destroy Resources

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/simple-deployment.yaml

# Destroy infrastructure
cd infrastructure
terraform destroy

# Confirm all resources are deleted in AWS Console
```

### Cost Monitoring

- **Monitor AWS billing** regularly
- **Stop/start EKS cluster** when not in use (manually)
- **Use AWS Cost Explorer** to track expenses
- **Set up billing alerts** for cost thresholds

## 🤝 Contributing

1. Fork repository and create feature branch
2. Make changes and test locally using `python run_tests.py`
3. **Use conventional PR titles** (see PR Title Conventions section above)
4. Submit pull request with descriptive conventional title

**Example PR Workflow:**
```bash
git checkout -b feat/new-monitoring
# Make changes with flexible commit messages
git commit -m "add prometheus integration"
git commit -m "update config for metrics"  
git commit -m "add tests and documentation"
git push origin feat/new-monitoring

# Create PR with conventional title:
# Title: "feat: add Prometheus metrics integration"
# Description: Details about the feature...

# PR validation checks → merge → automatic release
```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **GitHub Issues**: Report bugs and request features
- **Documentation**: Check this README and inline code comments
- **AWS Documentation**: [EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- **Terraform Documentation**: [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

Built with ❤️ for demonstrating cloud-native best practices
