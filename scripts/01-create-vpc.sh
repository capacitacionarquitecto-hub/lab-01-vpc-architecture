#!/bin/bash
set -e  # Exit on error — DevOps best practice

echo "🚀 Creating VPC..."

# Variables
REGION="us-east-1"
VPC_CIDR="10.0.0.0/16"
PROJECT_NAME="lab01-vpc"

# Create VPC
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --region $REGION \
  --query 'Vpc.VpcId' \
  --output text)

echo "✅ VPC created: $VPC_ID"

# Enable DNS hostnames (IMPORTANT for proper functionality)
aws ec2 modify-vpc-attribute \
  --vpc-id $VPC_ID \
  --enable-dns-hostnames

aws ec2 modify-vpc-attribute \
  --vpc-id $VPC_ID \
  --enable-dns-support

# Add tags (professional practice: ALWAYS tag resources)
aws ec2 create-tags \
  --resources $VPC_ID \
  --tags \
    Key=Name,Value=$PROJECT_NAME \
    Key=Environment,Value=lab \
    Key=Project,Value=portfolio \
    Key=ManagedBy,Value=manual

echo "✅ VPC configured successfully"
echo "📌 VPC_ID=$VPC_ID — Save this value!"

# Save to file for use in subsequent scripts
echo "export VPC_ID=$VPC_ID" >> ./scripts/env-vars.sh
echo "export REGION=$REGION" >> ./scripts/env-vars.sh
echo "export PROJECT_NAME=$PROJECT_NAME" >> ./scripts/env-vars.sh