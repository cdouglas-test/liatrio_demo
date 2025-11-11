#!/bin/bash

# Deploy script for Liatrio Demo API
# This script builds, pushes, and deploys the Flask API to EKS

set -e

# Configuration
AWS_REGION=${AWS_REGION:-"us-east-1"}
ECR_REPOSITORY=${ECR_REPOSITORY:-"liatrio-demo-dev-api"}
EKS_CLUSTER_NAME=${EKS_CLUSTER_NAME:-""}  # Will be retrieved from Terraform output
IMAGE_TAG=${IMAGE_TAG:-"manual-$(date +%Y%m%d%H%M%S)"}

echo "🚀 Starting deployment process..."
echo "Region: $AWS_REGION"
echo "ECR Repository: $ECR_REPOSITORY"

# Get EKS cluster name from Terraform output if not provided
if [ -z "$EKS_CLUSTER_NAME" ]; then
    echo "📋 Getting EKS cluster name from Terraform output..."
    pushd infrastructure > /dev/null
    terraform init -input=false
    EKS_CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
    popd > /dev/null
    echo "✅ Retrieved EKS cluster name: $EKS_CLUSTER_NAME"
fi

echo "EKS Cluster: $EKS_CLUSTER_NAME"
echo "Image Tag: $IMAGE_TAG"

# Check if AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS CLI not configured or credentials invalid"
    exit 1
fi

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY"

echo "📦 Building Docker image..."
cd app
docker build -t $ECR_REPOSITORY:$IMAGE_TAG .

echo "🔐 Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URI

echo "🏷️  Tagging image..."
docker tag $ECR_REPOSITORY:$IMAGE_TAG $ECR_URI:$IMAGE_TAG

echo "⬆️  Pushing image to ECR..."
docker push $ECR_URI:$IMAGE_TAG

echo "☸️  Updating kubeconfig..."
aws eks update-kubeconfig --region $AWS_REGION --name $EKS_CLUSTER_NAME

echo "📝 Updating Kubernetes manifests..."
cd ../k8s
cp deployment.yaml deployment-temp.yaml
sed -i "s|IMAGE_URI_PLACEHOLDER|$ECR_URI:$IMAGE_TAG|g" deployment-temp.yaml

echo "🚀 Deploying to Kubernetes..."
kubectl apply -f deployment-temp.yaml

echo "⏳ Waiting for deployment to complete..."
kubectl rollout status deployment/liatrio-demo-api -n default --timeout=300s

echo "🧹 Cleaning up temporary files..."
rm deployment-temp.yaml

echo "✅ Deployment completed successfully!"
echo ""
echo "📊 Deployment Status:"
kubectl get deployment liatrio-demo-api -n default
echo ""
echo "🎯 Service Information:"
kubectl get service liatrio-demo-api-service -n default
echo ""
echo "📋 Pod Status:"
kubectl get pods -l app=liatrio-demo-api -n default

# Get load balancer URL if available
echo ""
echo "🌐 Load Balancer URL:"
LB_URL=$(kubectl get ingress liatrio-demo-ingress -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "Not available yet")
if [ "$LB_URL" != "Not available yet" ]; then
    echo "http://$LB_URL/api"
else
    echo "Load balancer is still provisioning. Check in a few minutes with:"
    echo "kubectl get ingress liatrio-demo-ingress -n default"
fi

echo ""
echo "🔍 Test the API locally with port-forward:"
echo "kubectl port-forward service/liatrio-demo-api-service 8080:80"
echo "curl http://localhost:8080/api"