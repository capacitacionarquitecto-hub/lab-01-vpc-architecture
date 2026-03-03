#!/bin/bash
set -e
source ./scripts/env-vars.sh

echo "🔧 Creating subnets across multiple AZs..."

# --- PUBLIC SUBNETS ---────────────

PUBLIC_SUBNET_1=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block "10.0.1.0/24" \
  --availability-zone "${REGION}a" \
  --query 'Subnet.SubnetId' \
  --output text)

aws ec2 create-tags --resources $PUBLIC_SUBNET_1 \
  --tags Key=Name,Value="${PROJECT_NAME}-public-1a" \
         Key=Type,Value=public

PUBLIC_SUBNET_2=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block "10.0.2.0/24" \
  --availability-zone "${REGION}b" \
  --query 'Subnet.SubnetId' \
  --output text)

aws ec2 create-tags --resources $PUBLIC_SUBNET_2 \
  --tags Key=Name,Value="${PROJECT_NAME}-public-1b" \
         Key=Type,Value=public

# Enable auto-assignment of public IP on public subnets
aws ec2 modify-subnet-attribute \
  --subnet-id $PUBLIC_SUBNET_1 \
  --map-public-ip-on-launch

aws ec2 modify-subnet-attribute \
  --subnet-id $PUBLIC_SUBNET_2 \
  --map-public-ip-on-launch

echo "✅ Public subnets: $PUBLIC_SUBNET_1 | $PUBLIC_SUBNET_2"

# --- PRIVATE SUBNETS ---────────────

PRIVATE_SUBNET_1=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block "10.0.10.0/24" \
  --availability-zone "${REGION}a" \
  --query 'Subnet.SubnetId' \
  --output text)

aws ec2 create-tags --resources $PRIVATE_SUBNET_1 \
  --tags Key=Name,Value="${PROJECT_NAME}-private-1a" \
         Key=Type,Value=private

PRIVATE_SUBNET_2=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block "10.0.11.0/24" \
  --availability-zone "${REGION}b" \
  --query 'Subnet.SubnetId' \
  --output text)

aws ec2 create-tags --resources $PRIVATE_SUBNET_2 \
  --tags Key=Name,Value="${PROJECT_NAME}-private-1b" \
         Key=Type,Value=private

echo "✅ Private subnets: $PRIVATE_SUBNET_1 | $PRIVATE_SUBNET_2"

# --- DATA SUBNETS ---─────────────

DATA_SUBNET_1=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block "10.0.20.0/24" \
  --availability-zone "${REGION}a" \
  --query 'Subnet.SubnetId' \
  --output text)

aws ec2 create-tags --resources $DATA_SUBNET_1 \
  --tags Key=Name,Value="${PROJECT_NAME}-data-1a" \
         Key=Type,Value=data

DATA_SUBNET_2=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block "10.0.21.0/24" \
  --availability-zone "${REGION}b" \
  --query 'Subnet.SubnetId' \
  --output text)

aws ec2 create-tags --resources $DATA_SUBNET_2 \
  --tags Key=Name,Value="${PROJECT_NAME}-data-1b" \
         Key=Type,Value=data

echo "✅ Data subnets: $DATA_SUBNET_1 | $DATA_SUBNET_2"

# Save variables
cat >> ./scripts/env-vars.sh << EOF
export PUBLIC_SUBNET_1=$PUBLIC_SUBNET_1
export PUBLIC_SUBNET_2=$PUBLIC_SUBNET_2
export PRIVATE_SUBNET_1=$PRIVATE_SUBNET_1
export PRIVATE_SUBNET_2=$PRIVATE_SUBNET_2
export DATA_SUBNET_1=$DATA_SUBNET_1
export DATA_SUBNET_2=$DATA_SUBNET_2
EOF

echo "🎉 All subnets created successfully"