# Liatrio Demo - Cloud-Native Flask API

Enterprise Flask API with automated AWS EKS deployment, demonstrating modern DevOps practices including Infrastructure as Code, CI/CD pipelines, and security scanning.

## Features

- **Flask REST API** with `/api`, `/health`, `/metrics` endpoints
- **AWS EKS Deployment** with Terraform Infrastructure as Code
- **Automated CI/CD** with GitHub Actions, security scanning, and OIDC auth
- **Comprehensive Testing** - unit, integration, contract, and security validation
- **One-Command Deployment** scripts for complete environment setup

## Prerequisites

**Required Tools:** AWS CLI v2.x, Terraform v1.0+, kubectl, Docker, PowerShell 5.1+

**AWS Setup:** Account with EKS/EC2/VPC/IAM/ECR/S3/DynamoDB permissions, configured AWS CLI

**Estimated Cost:** ~$100/month for development usage

## Quick Start

### 1. Setup
```bash
git clone https://github.com/CRdouglas/liatrio_demo.git
cd liatrio_demo
aws configure  # Configure credentials
```

### 2. Deploy Infrastructure
```bash
cd infrastructure
terraform init
terraform apply -target=module.tfstate_backend -target=random_string.tfstate_suffix
terraform init -migrate-state
terraform apply  # Takes ~15-20 minutes
```

### 3. Deploy Application

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

**Option B: Manual Deployment**
```bash
.\scripts\deploy.ps1    # Windows
./scripts/deploy.sh     # Linux/macOS
```

## Development

### Local Development
```bash
cd app
pip install -r requirements.txt
python app.py  # Runs on http://localhost:8080

# Test with Docker
docker build -t liatrio-demo-api .
docker run -p 8080:8080 liatrio-demo-api
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
python run_tests.py  # Comprehensive test suite
python -m pytest test_app.py -v -m unit      # Unit tests only
python -m pytest test_app.py -v -m contract  # API compliance
```

**Test Coverage:** 24+ test cases, 90%+ code coverage, includes unit/integration/contract/security testing

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
- **Pull Requests:** PR title validation, build and test without deploying
- **Main Branch:** Full CI/CD pipeline with automatic versioning based on PR title
- **Release Creation:** Automatic GitHub releases with generated changelogs
- **Container Tagging:** Docker images tagged with semantic versions (v1.2.3)

## Project Structure

```text
liatrio_demo/
├── app/                    # Flask application & tests
├── infrastructure/         # Terraform IaC
├── k8s/                   # Kubernetes manifests  
├── .github/workflows/     # CI/CD pipelines
├── scripts/               # Deployment automation
└── README.md
```

## Troubleshooting

**Common Issues:**
- **Pod OOMKilled:** Current allocation: 128Mi request, 256Mi limit
- **Terraform State:** Use `terraform init -migrate-state` for backend issues
- **Pod Won't Start:** Check `kubectl describe pod <name>` and `kubectl logs <name>`
- **Load Balancer:** Allow 5-10 minutes for AWS ELB provisioning

## Configuration

**Multi-Environment Setup:**
```bash
terraform workspace new staging
terraform apply -var-file="staging.tfvars"
```

**Scaling:**
Modify `node_group_min/max/desired_size` in `terraform.tfvars`

## Cleanup

```bash
kubectl delete -f k8s/simple-deployment.yaml
cd infrastructure && terraform destroy
```

**Cost Monitoring:** Monitor AWS billing, use Cost Explorer, set billing alerts

## Contributing

1. Fork repository and create feature branch
2. Make changes and test locally using `python run_tests.py`
3. **Use conventional PR titles** (see PR Title Conventions section above)
4. Submit pull request with descriptive conventional title

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

## License & Support

MIT License - See [LICENSE](LICENSE) file

**Support:** GitHub Issues, [AWS EKS Docs](https://docs.aws.amazon.com/eks/latest/userguide/), [Terraform Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---
*Enterprise cloud-native Flask API demonstration project*
