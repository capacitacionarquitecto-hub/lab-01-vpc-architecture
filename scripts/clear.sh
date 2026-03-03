# Cuando termines de practicar, elimina los recursos en ESTE orden:
# (El orden importa por las dependencias)

# 1. Terminar instancias EC2
aws ec2 terminate-instances --instance-ids $BASTION_ID

# 2. Eliminar NAT Gateway (cobra por hora)
aws ec2 delete-nat-gateway --nat-gateway-id nat-0579ba1322bbc07b3

# 3. Esperar y liberar Elastic IP
aws ec2 wait nat-gateway-deleted --nat-gateway-ids nat-0579ba1322bbc07b3
aws ec2 release-address --allocation-id eipalloc-026b9529c829d20a7

# 4. Desadjuntar y eliminar IGW
aws ec2 detach-internet-gateway --internet-gateway-id igw-0e7a89d5987fd1062 --vpc-id vpc-01acc2fc7c4394181
aws ec2 delete-internet-gateway --internet-gateway-id igw-0e7a89d5987fd1062

# 5. Eliminar subnets
for subnet in subnet-01628d76bdabd88a2 subnet-0e906b2484284b911 subnet-091c55172de2528dc subnet-0eb13338394a53c89 subnet-073c8e46130ece8a8 subnet-0589affb505280929; do
  aws ec2 delete-subnet --subnet-id $subnet
done

# 6. Eliminar Security Groups
aws ec2 delete-security-group --group-id $SG_DB
aws ec2 delete-security-group --group-id $SG_APP
aws ec2 delete-security-group --group-id $SG_BASTION

# 7. Eliminar Route Tables
aws ec2 delete-route-table --route-table-id rtb-0160231fdd0bbff11
aws ec2 delete-route-table --route-table-id $PRIVATE_RT
aws ec2 delete-route-table --route-table-id $DATA_RT

# 8. Finalmente eliminar la VPC
aws ec2 delete-vpc --vpc-id vpc-01acc2fc7c4394181

echo "🧹 Recursos eliminados correctamente"