#!/bin/bash
# Variables throughout the project.

# Every resources created on AWS will be named with this prefix.
# dc = Data (Records) Collection
project_name="aws-dc"
# Kinesis Data Stream lambda consumer image repository.
lambda_consumer_ecr_repo="$project_name-lambda-consumer"
# Project will be deloyed on this region.
deployment_region="$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')"
# S3 bucket for intermediate/temp files during deployment.
deployment_bucket="$project_name-deployment-$deployment_region"
# Latest Amazon Linux 2 AMI ID. Base image for image builder.
amz_linux_2_ami="$(aws ssm get-parameters \
  --names '/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2' \
  --query 'Parameters[0].[Value]' \
  --output text)"
# AWS Account ID for this deployment.
aws_account_id="$(aws sts get-caller-identity --output text --query 'Account')"
# Fluent Bit config.
# http input plugin, listen port.
fluentbit_http_port="7891"
# kinesis data stream ouput plugin, kinesis data stream name.
fluentbit_kinesis_stream="$project_name-stream"
#
fluentbit_instance_type="t3.small"
# Image Builder version
ib_component_version="1.0.1"
ib_image_recipe_version="1.0.1"
# Fluent Bit cluster ASG
asg_min_capacity=1;
asg_max_capacity=1;
asg_desired_capacity=1;

echo "config.sh imported..."
