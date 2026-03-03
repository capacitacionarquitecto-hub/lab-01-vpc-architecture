# scripts/04-create-route-tables.sh

#!/bin/bash
set -e
source ./scripts/env-vars.sh

echo "🗺️ Configuring route tables..."

# ─── ROUTE TABLE PÚBLICA ──────────────────────────────────────
# Tráfico hacia Internet va por el IGW

PUBLIC_RT=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --query 'RouteTable.RouteTableId' \
  --output text)

aws ec2 create-tags --resources $PUBLIC_RT \
  --tags Key=Name,Value="${PROJECT_NAME}-public-rt"

# Ruta: todo el tráfico (0.0.0.0/0) va al IGW
aws ec2 create-route \
  --route-table-id $PUBLIC_RT \
  --destination-cidr-block "0.0.0.0/0" \
  --gateway-id $IGW_ID

# Associate public subnets with this route table
aws ec2 associate-route-table \
  --route-table-id $PUBLIC_RT \
  --subnet-id $PUBLIC_SUBNET_1

aws ec2 associate-route-table \
  --route-table-id $PUBLIC_RT \
  --subnet-id $PUBLIC_SUBNET_2

echo "✅ Public route table configured: $PUBLIC_RT"

# ─── ROUTE TABLE PRIVADA ──────────────────────────────────────
# Tráfico saliente va por NAT Gateway

PRIVATE_RT=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --query 'RouteTable.RouteTableId' \
  --output text)

aws ec2 create-tags --resources $PRIVATE_RT \
  --tags Key=Name,Value="${PROJECT_NAME}-private-rt"

# Ruta: tráfico de salida va al NAT Gateway
aws ec2 create-route \
  --route-table-id $PRIVATE_RT \
  --destination-cidr-block "0.0.0.0/0" \
  --nat-gateway-id $NAT_GW_ID

aws ec2 associate-route-table \
  --route-table-id $PRIVATE_RT \
  --subnet-id $PRIVATE_SUBNET_1

aws ec2 associate-route-table \
  --route-table-id $PRIVATE_RT \
  --subnet-id $PRIVATE_SUBNET_2

echo "✅ Private route table configured: $PRIVATE_RT"

# ─── ROUTE TABLE DE DATOS ─────────────────────────────────────
# Las bases de datos NO necesitan salida a Internet (máxima seguridad)

DATA_RT=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --query 'RouteTable.RouteTableId' \
  --output text)

aws ec2 create-tags --resources $DATA_RT \
  --tags Key=Name,Value="${PROJECT_NAME}-data-rt"

# SIN ruta a Internet — tráfico solo interno
aws ec2 associate-route-table \
  --route-table-id $DATA_RT \
  --subnet-id $DATA_SUBNET_1

aws ec2 associate-route-table \
  --route-table-id $DATA_RT \
  --subnet-id $DATA_SUBNET_2

echo "✅ Data route table configured (no Internet access): $DATA_RT"

cat >> ./scripts/env-vars.sh << EOF
export PUBLIC_RT=$PUBLIC_RT
export PRIVATE_RT=$PRIVATE_RT
export DATA_RT=$DATA_RT
EOF