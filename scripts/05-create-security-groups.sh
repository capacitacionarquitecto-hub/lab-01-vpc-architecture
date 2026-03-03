#!/bin/bash
set -e
source ./scripts/env-vars.sh

echo "🔒 Creating Security Groups..."

# --- SG: BASTION HOST ---
# Solo permite SSH desde tu IP actual

MY_IP=$(curl -s https://checkip.amazonaws.com)/32
echo "Tu IP actual: $MY_IP"

SG_BASTION=$(aws ec2 create-security-group \
  --group-name "${PROJECT_NAME}-bastion-sg" \
  --description "Security group for Bastion Host" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text)

aws ec2 create-tags --resources $SG_BASTION \
  --tags Key=Name,Value="${PROJECT_NAME}-bastion-sg"

# Solo SSH desde tu IP
aws ec2 authorize-security-group-ingress \
  --group-id $SG_BASTION \
  --protocol tcp \
  --port 22 \
  --cidr $MY_IP

echo "✅ Bastion SG created: $SG_BASTION (SSH only from $MY_IP)"

# ─── SG: APP SERVERS ──────────────────────────────────────────
# Allows traffic only from the Bastion (SSH) and ALB (HTTP/HTTPS)

SG_APP=$(aws ec2 create-security-group \
  --group-name "${PROJECT_NAME}-app-sg" \
  --description "Security group para App Servers" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text)

aws ec2 create-tags --resources $SG_APP \
  --tags Key=Name,Value="${PROJECT_NAME}-app-sg"

# SSH only from Bastion (reference SG, not IP — best practice)
aws ec2 authorize-security-group-ingress \
  --group-id $SG_APP \
  --protocol tcp \
  --port 22 \
  --source-group $SG_BASTION

# HTTP desde cualquier lugar dentro de la VPC
aws ec2 authorize-security-group-ingress \
  --group-id $SG_APP \
  --protocol tcp \
  --port 80 \
  --cidr "10.0.0.0/16"

aws ec2 authorize-security-group-ingress \
  --group-id $SG_APP \
  --protocol tcp \
  --port 443 \
  --cidr "10.0.0.0/16"

echo "✅ SG App Servers creado: $SG_APP"

# ─── SG: BASES DE DATOS ───────────────────────────────────────
# Solo acepta conexiones desde los App Servers

SG_DB=$(aws ec2 create-security-group \
  --group-name "${PROJECT_NAME}-db-sg" \
  --description "Security group para Bases de Datos" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text)

aws ec2 create-tags --resources $SG_DB \
  --tags Key=Name,Value="${PROJECT_NAME}-db-sg"

# MySQL/PostgreSQL solo desde App Servers
aws ec2 authorize-security-group-ingress \
  --group-id $SG_DB \
  --protocol tcp \
  --port 3306 \
  --source-group $SG_APP

aws ec2 authorize-security-group-ingress \
  --group-id $SG_DB \
  --protocol tcp \
  --port 5432 \
  --source-group $SG_APP

echo "✅ SG Bases de Datos creado: $SG_DB"

cat >> ./scripts/env-vars.sh << EOF
export SG_BASTION=$SG_BASTION
export SG_APP=$SG_APP
export SG_DB=$SG_DB
export MY_IP=$MY_IP
EOF