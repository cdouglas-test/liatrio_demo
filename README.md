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

```bash
cd infrastructure

# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Deploy infrastructure (takes ~15-20 minutes)
terraform apply
```

### 4. Deploy Application

#### Option A: Automated CI/CD (Recommended)

1. **Fork this repository** to your GitHub account
2. **Set up GitHub Environment** named `dev`
3. **Configure AWS OIDC Role** in GitHub environment variables:

   ```bash
   AWS_ROLE_ARN = arn:aws:iam::YOUR_ACCOUNT:role/github-actions-role
   ```

4. **Push to main branch** - CI/CD pipeline will automatically deploy

#### Option B: Manual Deployment

```powershell
# From project root directory
.\scripts\deploy.ps1
```

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

1. **Fork the repository**
2. **Create feature branch**: `git checkout -b feature/amazing-feature`
3. **Make changes** and test locally
4. **Commit changes**: `git commit -m 'Add amazing feature'`
5. **Push to branch**: `git push origin feature/amazing-feature`
6. **Open Pull Request**

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **GitHub Issues**: Report bugs and request features
- **Documentation**: Check this README and inline code comments
- **AWS Documentation**: [EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- **Terraform Documentation**: [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

Built with ❤️ for demonstrating cloud-native best practices
