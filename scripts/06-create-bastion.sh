# scripts/06-create-bastion.sh

#!/bin/bash
set -e
source ./scripts/env-vars.sh

echo "🖥️ Creating Bastion Host..."

# Crear Key Pair
aws ec2 create-key-pair \
  --key-name "${PROJECT_NAME}-key" \
  --query 'KeyMaterial' \
  --output text > capacitacion/.ssh/${PROJECT_NAME}-key.pem

chmod 400 capacitacion/.ssh/${PROJECT_NAME}-key.pem
echo "✅ Key pair created"

# Obtener última Amazon Linux 2023 AMI
AMI_ID=$(aws ec2 describe-images \
  --owners amazon \
  --filters \
    "Name=name,Values=al2023-ami-*-x86_64" \
    "Name=state,Values=available" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
  --output text)

echo "📌 AMI: $AMI_ID"

# Create Bastion Host (minimal instance to save costs)
BASTION_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.micro \
  --key-name "${PROJECT_NAME}-key" \
  --security-group-ids $SG_BASTION \
  --subnet-id $PUBLIC_SUBNET_1 \
  --associate-public-ip-address \
  --tag-specifications \
    "ResourceType=instance,Tags=[{Key=Name,Value=${PROJECT_NAME}-bastion},{Key=Role,Value=bastion}]" \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "⏳ Waiting for the Bastion to be running..."
aws ec2 wait instance-running --instance-ids $BASTION_ID

BASTION_IP=$(aws ec2 describe-instances \
  --instance-ids $BASTION_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "✅ Bastion Host listo: $BASTION_ID | IP: $BASTION_IP"

# ─── VPC FLOW LOGS ────────────────────────────────────────────
# Registra TODO el tráfico de red — esencial para seguridad y auditoría

# Crear grupo de logs en CloudWatch
aws logs create-log-group \
  --log-group-name "/aws/vpc/${PROJECT_NAME}-flow-logs"

# Crear IAM role para Flow Logs (simplificado)
FLOW_LOG_ID=$(aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids $VPC_ID \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name "/aws/vpc/${PROJECT_NAME}-flow-logs" \
  --deliver-logs-permission-arn "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/VPCFlowLogsRole" \
  --query 'FlowLogIds[0]' \
  --output text 2>/dev/null || echo "Configura Flow Logs manualmente en la consola")

echo "✅ VPC Flow Logs configurados"
echo ""
echo "═══════════════════════════════════════════"
echo "🎉 LAB-01 COMPLETADO"
echo "═══════════════════════════════════════════"
echo "VPC ID:        $VPC_ID"
echo "Bastion IP:    $BASTION_IP"
echo "SSH Command:   ssh -i ~/.ssh/${PROJECT_NAME}-key.pem ec2-user@$BASTION_IP"
echo "═══════════════════════════════════════════"