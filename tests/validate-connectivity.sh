#!/bin/bash
source ./scripts/env-vars.sh

echo "🧪 Validando arquitectura..."

# 1. Verificar VPC
echo -n "VPC existe: "
aws ec2 describe-vpcs --vpc-ids $VPC_ID \
  --query 'Vpcs[0].State' --output text

# 2. Verify subnets
echo -n "Cantidad de subnets: "
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'length(Subnets)' --output text

# 3. Verificar IGW adjunto
echo -n "IGW adjunto: "
aws ec2 describe-internet-gateways \
  --internet-gateway-ids $IGW_ID \
  --query 'InternetGateways[0].Attachments[0].State' --output text

# 4. Verificar NAT Gateway
echo -n "NAT Gateway estado: "
aws ec2 describe-nat-gateways \
  --nat-gateway-ids $NAT_GW_ID \
  --query 'NatGateways[0].State' --output text

# 5. Verificar Security Groups
echo -n "Security Groups creados: "
aws ec2 describe-security-groups \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'length(SecurityGroups)' --output text

echo ""
echo "✅ Validación completada"