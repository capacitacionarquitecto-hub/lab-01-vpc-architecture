#!/bin/bash
set -e  # Sale si hay error — buena práctica DevOps

echo "🚀 Creando VPC..."

# Variables
REGION="us-east-1"
VPC_CIDR="10.0.0.0/16"
PROJECT_NAME="lab01-vpc"

# Crear VPC
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --region $REGION \
  --query 'Vpc.VpcId' \
  --output text)

echo "✅ VPC creada: $VPC_ID"

# Habilitar DNS hostnames (IMPORTANTE para que funcione bien)
aws ec2 modify-vpc-attribute \
  --vpc-id $VPC_ID \
  --enable-dns-hostnames

aws ec2 modify-vpc-attribute \
  --vpc-id $VPC_ID \
  --enable-dns-support

# Agregar tags (práctica profesional SIEMPRE taggear)
aws ec2 create-tags \
  --resources $VPC_ID \
  --tags \
    Key=Name,Value=$PROJECT_NAME \
    Key=Environment,Value=lab \
    Key=Project,Value=portfolio \
    Key=ManagedBy,Value=manual

echo "✅ VPC configurada correctamente"
echo "📌 VPC_ID=$VPC_ID — Guarda este valor!"

# Guardar en archivo para usar en siguientes scripts
echo "export VPC_ID=$VPC_ID" >> ./scripts/env-vars.sh
echo "export REGION=$REGION" >> ./scripts/env-vars.sh
echo "export PROJECT_NAME=$PROJECT_NAME" >> ./scripts/env-vars.sh