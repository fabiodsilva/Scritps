#!/bin/bash
USEDMEMORY=$(awk '/^Mem/ {printf("%u", 100*$3/$2);}' <(free -m))
PROC=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.1f\n", usage }')

INSTANCE=$(curl curl -s http://169.254.169.254/latest/meta-data/instance-id)

aws cloudwatch put-metric-data --region "sa-east-1" --metric-name MemoryUsage --dimensions instance_id=$INSTANCE --namespace "ASGCustom-Per-instance" --value $USEDMEMORY
echo "RAM done"

aws cloudwatch put-metric-data --region "sa-east-1" --metric-name CPUUsage  --dimensions instance_id=$INSTANCE --namespace "ASGCustom-Per-instance" --value $PROC
echo "CPU done"


ASG=`aws ec2 describe-tags     --filters "Name=resource-id,Values=$INSTANCE" --region sa-east-1 --output text | grep "aws:autoscaling:groupName" | awk  '{ print$5 }'`



if [[ $ASG = ASGteste ]];
then

echo $ASG
aws cloudwatch put-metric-data --region "sa-east-1" --metric-name MemoryUsage --dimensions instance_id=$INSTANCE --namespace "ASGCustom-Per-instance-Mobile" --value $USEDMEMORY
echo "RAM done"

aws cloudwatch put-metric-data --region "sa-east-1" --metric-name CPUUsage  --dimensions instance_id=$INSTANCE --namespace "ASGCustom-Per-instance-Mobile" --value $PROC
echo "CPU done"

else
if  [[ $ASG = ASGteste ]];
then
echo $ASG
aws cloudwatch put-metric-data --region "sa-east-1" --metric-name MemoryUsage --dimensions instance_id=$INSTANCE --namespace "ASGCustom-Per-instance-Parceiro" --value $USEDMEMORY
echo "RAM done"

aws cloudwatch put-metric-data --region "sa-east-1" --metric-name CPUUsage  --dimensions instance_id=$INSTANCE --namespace "ASGCustom-Per-instance-Parceiro" --value $PROC
echo "CPU done"

fi
fi