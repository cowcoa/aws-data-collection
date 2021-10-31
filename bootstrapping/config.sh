#!/bin/bash
# Variables throughout the project.

# Every resources created on AWS will be named with this prefix.
# dc = Data (Records) Collection
project_name="aws-dc"
# AWS Account Number for this deployment.
aws_account_id="$(aws sts get-caller-identity --output text --query 'Account')"
# Project will be deloyed on this region.
deployment_region="$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')"
# S3 bucket for intermediate/temp files during deployment.
s3_deployment_bucket="$project_name-deployment-$deployment_region"
# S3 bucket for data records storage
s3_data_records_bucket="$project_name-data-records-$deployment_region"
# Kinesis Data Stream lambda consumer image repository.
ecr_lambda_consumer_repo="$project_name-lambda-consumer"
# lambda consumer image repository URI.
ecr_lambda_consumer_repo_uri=$aws_account_id.dkr.ecr.$deployment_region.amazonaws.com/$lambda_consumer_ecr_repo
# Image Builder AWSTOE component version.
ib_component_version="1.0.0"
# Image Builder image recipe version.
ib_image_recipe_version="1.0.0"
# Latest Amazon Linux 2 AMI ID. Base image for image builder.
ib_amz_linux_2_ami="$(aws ssm get-parameters \
  --names '/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2' \
  --query 'Parameters[0].[Value]' \
  --output text)"
# http input plugin, listen port.
fb_http_port="7891"
# kinesis data stream ouput plugin, kinesis data stream name.
fb_kinesis_stream="$project_name-stream"
# Fluent Bit cluster instance type/size.
fb_instance_type="t3.small"
# Fluent Bit log level. Allowed values are: error, warn, info, debug and trace.
fb_log_level="debug"
#
fb_instance_key_pair="opalcube-aws-us-west-2-key-pair"
#fb_instance_key_pair=""
# Fluent Bit cluster ASG
asg_min_capacity=1
asg_max_capacity=2
asg_desired_capacity=1
# Kinesis Data Stream
kds_shard_count=1
# NLB
nlb_listener_port=8080

echo "config.sh imported."
