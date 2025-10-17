#!/bin/bash

# AWS AI Governance Framework - Deployment Script
# This script automates the deployment to AWS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
ECS_CLUSTER="grc-cluster"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}AWS AI Governance Framework Deployment${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "AWS Account: ${AWS_ACCOUNT_ID}"
echo "Region: ${AWS_REGION}"
echo ""

# Function to print status
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v aws &> /dev/null; then
    print_error "AWS CLI not found. Please install it first."
    exit 1
fi
print_status "AWS CLI installed"

if ! command -v docker &> /dev/null; then
    print_error "Docker not found. Please install it first."
    exit 1
fi
print_status "Docker installed"

if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured. Run 'aws configure' first."
    exit 1
fi
print_status "AWS credentials configured"

echo ""

# Login to ECR
echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region ${AWS_REGION} | \
    docker login --username AWS --password-stdin ${ECR_REGISTRY}
print_status "Logged in to ECR"

echo ""

# Build and push backend
echo "Building and pushing backend image..."
cd webapp/backend
docker build -t grc-backend .
docker tag grc-backend:latest ${ECR_REGISTRY}/grc-backend:latest
docker tag grc-backend:latest ${ECR_REGISTRY}/grc-backend:$(git rev-parse --short HEAD)
docker push ${ECR_REGISTRY}/grc-backend:latest
docker push ${ECR_REGISTRY}/grc-backend:$(git rev-parse --short HEAD)
print_status "Backend image pushed"
cd ../..

echo ""

# Build and push celery worker (same image as backend)
echo "Pushing celery worker image..."
docker tag grc-backend:latest ${ECR_REGISTRY}/grc-celery-worker:latest
docker tag grc-backend:latest ${ECR_REGISTRY}/grc-celery-worker:$(git rev-parse --short HEAD)
docker push ${ECR_REGISTRY}/grc-celery-worker:latest
docker push ${ECR_REGISTRY}/grc-celery-worker:$(git rev-parse --short HEAD)
print_status "Celery worker image pushed"

echo ""

# Build and push frontend
echo "Building and pushing frontend image..."
cd webapp/frontend
docker build -f Dockerfile.prod -t grc-frontend .
docker tag grc-frontend:latest ${ECR_REGISTRY}/grc-frontend:latest
docker tag grc-frontend:latest ${ECR_REGISTRY}/grc-frontend:$(git rev-parse --short HEAD)
docker push ${ECR_REGISTRY}/grc-frontend:latest
docker push ${ECR_REGISTRY}/grc-frontend:$(git rev-parse --short HEAD)
print_status "Frontend image pushed"
cd ../..

echo ""

# Update ECS services
echo "Updating ECS services..."

# Update backend service
if aws ecs describe-services --cluster ${ECS_CLUSTER} --services grc-backend-service &> /dev/null; then
    aws ecs update-service \
        --cluster ${ECS_CLUSTER} \
        --service grc-backend-service \
        --force-new-deployment \
        --query 'service.serviceName' \
        --output text > /dev/null
    print_status "Backend service updated"
else
    print_warning "Backend service not found. Skipping update."
fi

# Update celery worker service
if aws ecs describe-services --cluster ${ECS_CLUSTER} --services grc-celery-service &> /dev/null; then
    aws ecs update-service \
        --cluster ${ECS_CLUSTER} \
        --service grc-celery-service \
        --force-new-deployment \
        --query 'service.serviceName' \
        --output text > /dev/null
    print_status "Celery worker service updated"
else
    print_warning "Celery worker service not found. Skipping update."
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Images pushed:"
echo "  - ${ECR_REGISTRY}/grc-backend:latest"
echo "  - ${ECR_REGISTRY}/grc-celery-worker:latest"
echo "  - ${ECR_REGISTRY}/grc-frontend:latest"
echo ""
echo "Git commit: $(git rev-parse --short HEAD)"
echo ""
echo "Monitor deployment:"
echo "  aws ecs describe-services --cluster ${ECS_CLUSTER} --services grc-backend-service"
echo ""
