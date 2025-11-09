# Deploy script for Liatrio Demo API (PowerShell)
# This script builds, pushes, and deploys the Flask API to EKS

param(
    [string]$AwsRegion = "us-east-1",
    [string]$EcrRepository = "liatrio-demo-dev-api",
    [string]$EksClusterName = "liatrio-demo-dev-eks-u58x74nr",
    [string]$ImageTag = "manual-$(Get-Date -Format 'yyyyMMddHHmmss')"
)

$ErrorActionPreference = "Stop"

Write-Host "Starting deployment process..." -ForegroundColor Green
Write-Host "Region: $AwsRegion" -ForegroundColor Cyan
Write-Host "ECR Repository: $EcrRepository" -ForegroundColor Cyan
Write-Host "EKS Cluster: $EksClusterName" -ForegroundColor Cyan
Write-Host "Image Tag: $ImageTag" -ForegroundColor Cyan

# Check if AWS CLI is configured
try {
    $null = aws sts get-caller-identity 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "AWS CLI not configured"
    }
} catch {
    Write-Host "AWS CLI not configured or credentials invalid" -ForegroundColor Red
    exit 1
}

# Get AWS account ID
$AwsAccountId = aws sts get-caller-identity --query Account --output text
$EcrUri = "$AwsAccountId.dkr.ecr.$AwsRegion.amazonaws.com/$EcrRepository"

Write-Host "Building Docker image..." -ForegroundColor Yellow
Set-Location app
docker build -t "$EcrRepository`:$ImageTag" .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed" -ForegroundColor Red
    exit 1
}

Write-Host "🔐 Logging into ECR..." -ForegroundColor Yellow
$LoginCommand = aws ecr get-login-password --region $AwsRegion
$LoginCommand | docker login --username AWS --password-stdin $EcrUri

if ($LASTEXITCODE -ne 0) {
    Write-Host "ECR login failed" -ForegroundColor Red
    exit 1
}

Write-Host "🏷️  Tagging image..." -ForegroundColor Yellow
docker tag "$EcrRepository`:$ImageTag" "$EcrUri`:$ImageTag"

Write-Host "⬆️  Pushing image to ECR..." -ForegroundColor Yellow
docker push "$EcrUri`:$ImageTag"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker push failed" -ForegroundColor Red
    exit 1
}

Write-Host "☸️  Updating kubeconfig..." -ForegroundColor Yellow
aws eks update-kubeconfig --region $AwsRegion --name $EksClusterName

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to update kubeconfig" -ForegroundColor Red
    exit 1
}

Write-Host "📝 Updating Kubernetes manifests..." -ForegroundColor Yellow
Set-Location ../k8s
Copy-Item deployment.yaml deployment-temp.yaml
(Get-Content deployment-temp.yaml) -replace "IMAGE_URI_PLACEHOLDER", "$EcrUri`:$ImageTag" | Set-Content deployment-temp.yaml

Write-Host "Deploying to Kubernetes..." -ForegroundColor Yellow
kubectl apply -f deployment-temp.yaml

if ($LASTEXITCODE -ne 0) {
    Write-Host "Kubernetes deployment failed" -ForegroundColor Red
    Remove-Item deployment-temp.yaml -Force
    exit 1
}

Write-Host "Waiting for deployment to complete..." -ForegroundColor Yellow
kubectl rollout status deployment/liatrio-demo-api -n default --timeout=300s

Write-Host "🧹 Cleaning up temporary files..." -ForegroundColor Yellow
Remove-Item deployment-temp.yaml -Force

Write-Host "Deployment completed successfully!" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Deployment Status:" -ForegroundColor Cyan
kubectl get deployment liatrio-demo-api -n default
Write-Host ""

Write-Host "🎯 Service Information:" -ForegroundColor Cyan
kubectl get service liatrio-demo-api-service -n default
Write-Host ""

Write-Host "📋 Pod Status:" -ForegroundColor Cyan
kubectl get pods -l app=liatrio-demo-api -n default

# Get load balancer URL if available
Write-Host ""
Write-Host "Load Balancer URL:" -ForegroundColor Cyan
try {
    $LbUrl = kubectl get ingress liatrio-demo-ingress -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>$null
    if ($LbUrl -and $LbUrl -ne "") {
        Write-Host "http://$LbUrl/api" -ForegroundColor Green
    } else {
        Write-Host "Load balancer is still provisioning. Check in a few minutes with:" -ForegroundColor Yellow
        Write-Host "kubectl get ingress liatrio-demo-ingress -n default" -ForegroundColor Gray
    }
} catch {
    Write-Host "Load balancer is still provisioning. Check in a few minutes with:" -ForegroundColor Yellow
    Write-Host "kubectl get ingress liatrio-demo-ingress -n default" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Test the API locally with port-forward:" -ForegroundColor Cyan
Write-Host "kubectl port-forward service/liatrio-demo-api-service 8080:80" -ForegroundColor Gray
Write-Host "curl http://localhost:8080/api" -ForegroundColor Gray