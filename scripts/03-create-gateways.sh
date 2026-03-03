#!/bin/bash
set -e
source ./scripts/env-vars.sh

echo "🌐 Configuring gateways..."

# ─── INTERNET GATEWAY ────────────────────────────────────────
# Permite que la VPC se comunique con Internet

IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

aws ec2 create-tags --resources $IGW_ID \
  --tags Key=Name,Value="${PROJECT_NAME}-igw"

# Adjuntar IGW a la VPC
aws ec2 attach-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --vpc-id $VPC_ID

echo "✅ Internet Gateway creado y adjuntado: $IGW_ID"

# ─── ELASTIC IP para NAT Gateway ─────────────────────────────
# El NAT Gateway necesita una IP pública estática

EIP_ALLOC=$(aws ec2 allocate-address \
  --domain vpc \
  --query 'AllocationId' \
  --output text)

aws ec2 create-tags --resources $EIP_ALLOC \
  --tags Key=Name,Value="${PROJECT_NAME}-nat-eip"

echo "✅ Elastic IP asignada: $EIP_ALLOC"

# ─── NAT GATEWAY ─────────────────────────────────────────────
# Allows PRIVATE subnets to access the Internet (outbound only)
# Va en subnet PÚBLICA — esto es importante y se pregunta en entrevistas

NAT_GW_ID=$(aws ec2 create-nat-gateway \
  --subnet-id $PUBLIC_SUBNET_1 \
  --allocation-id $EIP_ALLOC \
  --query 'NatGateway.NatGatewayId' \
  --output text)

aws ec2 create-tags --resources $NAT_GW_ID \
  --tags Key=Name,Value="${PROJECT_NAME}-nat-gw"

echo "⏳ Waiting for NAT Gateway to be available..."
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GW_ID
echo "✅ NAT Gateway disponible: $NAT_GW_ID"

# Save variables
cat >> ./scripts/env-vars.sh << EOF
export IGW_ID=$IGW_ID
export NAT_GW_ID=$NAT_GW_ID
export EIP_ALLOC=$EIP_ALLOC
EOF