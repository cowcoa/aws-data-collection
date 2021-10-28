#!/bin/bash
# Variables throughout the project.

# Every resources created on AWS will be named with this prefix.
# drc = Data Records Collection
project_name="rg-drc"
# 
ecr_lambda_consumer_repo="$project_name-lambda-consumer"
# Project will be deloyed on this region.
deployment_region="$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')"
# S3 bucket for intermediate/temp files during deployment.
s3_bucket_deployment="$project_name-deployment-$deployment_region"
# EC2 Instance role for image builder.
# All IAM actions that interact with roles are allowed only for role names starting with Cloud9-.
image_builder_ec2_role="Cloud9-$project_name-EC2InstanceProfileForImageBuilder"
parent_image="$(aws ssm get-parameters \
  --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 \
  --output text \
  --query 'Parameters[0].[Value]')"
  
default_vpc="$(aws ec2 describe-vpcs \
  --filters Name=isDefault,Values=true \
  --query 'Vpcs[*].VpcId' \
  --output text)"
default_subnets="$(aws ec2 describe-subnets \
  --filters Name=vpc-id,Values=$default_vpc \
  --query "Subnets[].SubnetId" \
  --output text)"
echo $default_subnets
default_subnets=$(echo $default_subnets | sed 's/ /\\,/g')
echo $default_subnets

account_id="$(aws sts get-caller-identity --output text --query 'Account')"

#mysubnets=($default_subnets)
#new_subnets=""
#for i in "${mysubnets[@]}"
#do
#  :
  # do whatever on $i
#  echo $i
#  new_subnets+="\"$i\","
#done
#new_subnets=$(echo $new_subnets | sed 's/.$//')
#echo $new_subnets

echo "Variables imported."
