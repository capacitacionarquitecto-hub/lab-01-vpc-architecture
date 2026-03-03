#!/usr/bin/env bash
set -euo pipefail

# validate-connectivity.sh
# Script de validación básico para el laboratorio.

echo "Verificaciones sugeridas:\n- Comprobar que la VPC existe (aws ec2 describe-vpcs)\n- Comprobar subnets (aws ec2 describe-subnets)\n- Comprobar que el Internet Gateway está adjunto\n- Probar SSH desde Bastion a instancias privadas (si aplica)"

# Ejemplo de chequeo (requiere AWS CLI configurado):
# aws ec2 describe-vpcs --filters "Name=tag:Name,Values=lab-vpc"
