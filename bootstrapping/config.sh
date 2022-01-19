#!/bin/bash
# Variables throughout the project.

# Every resources created on AWS will be named with this prefix.
# dc = Data (Records) Collection
project_name="aws-dc-nginx"
# AWS Account Number for this deployment.
aws_account_id="$(aws sts get-caller-identity --output text --query 'Account')"
# Deployment environment. Allowed values are: dev, prod.
# If you deploy this project in development env, all vpc subnets will be public.
deployment_env="dev"
# Project will be deloyed on this region.
deployment_region="$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')"
# Add suffix to avoid bucket name conflicts.
s3_bucket_suffix="${aws_account_id: -4}"
# S3 bucket for intermediate/temp files during deployment.
s3_deployment_bucket="$project_name-deployment-$deployment_region-$s3_bucket_suffix"
# S3 bucket for data records storage.
s3_data_records_bucket="$project_name-data-records-$deployment_region-$s3_bucket_suffix"
# Kinesis stream's lambda consumer image repository.
ecr_lambda_consumer_repo="$project_name-lambda-consumer"
# Lambda consumer image repository URI.
ecr_lambda_consumer_repo_uri=$aws_account_id.dkr.ecr.$deployment_region.amazonaws.com/$ecr_lambda_consumer_repo
# Image Builder AWSTOE component version.
# If you're about to re-build Nginx/FluentBit AMI(after updating configuration files),
# you MUST update this version number(Must follow "x.x.x" format).
ib_component_version="1.0.0"
# Image Builder image recipe version.
# If you update ib_component_version, you MUST also update this version(with the same format).
ib_image_recipe_version="1.0.0"
# Latest Amazon Linux 2 AMI ID. Base image for image builder.
# ib_amz_linux_2_ami="/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
ib_amz_linux_2_ami="/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-arm64-gp2"
# Fluent-Bit configuration variables.
# Kinesis stream ouput plugin, kinesis data stream name.
fb_kinesis_stream="$project_name-stream"
# Fluent Bit log level. Allowed values are: error, warn, info, debug and trace.
fb_log_level="debug"
# Enable Nginx or not. Allowed values are: true, false.
nginx_enable="true"
# ** SKIP Image Builder steps **, and use this AMI to launch EC2 instances.
ec2_ami_id=""
# EC2 instance HTTP listen port.
ec2_http_port="7891"
# Fluent Bit cluster instance type/size.
# Instance type MUST match AMI architecture.
# E.g, x6g for arm64 architecture, x5 for x86_64 architecture.
ec2_instance_type="m6g.medium"
# Fluent Bit instance's key pair name.
# If you don't want to specify a key pair, leave this variable to empty.
ec2_instance_key_pair="opalcube-aws-us-west-2-key-pair"
# Fluent Bit cluster ASG.
# The ASG always keep 1 instance in running status. you MUST set max capacity greater than min capacity.
asg_min_capacity=1
asg_max_capacity=3
asg_desired_capacity=1
# The type of load balancer. Allowed values are: application, network
elb_type="application"
# ELB's listener port. ELB will forward request from elb_listener_port to ec2_http_port.
elb_listener_port=80
# ELB's ACM certificate that contained custom domain name.
# If you just want to use HTTP protocal, leave this config variable to empty.
elb_certificate="arn:aws:acm:us-west-2:027226252545:certificate/9135d3b4-dfc3-48a9-80c4-fce59654af3f"
# Whether to enable Global Accelerator.
aga_enable="true"
# Kinesis stream mode. Allowed values are: ON_DEMAND, PROVISIONED
kds_stream_mode="ON_DEMAND"
# Kinesis stream shard count.
# Only valid when kds_stream_mode is PROVISIONED.
kds_shard_count=1
# Kinesis data retention period, unit is Hour. Allowed value range: [24, 8760(365 days)]
kds_retention_hours=24
# Kinesis Data Firehose.
# Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination.
# Allowed value range: [60, 900]
kdf_buffer_time=60
# Buffer incoming data to the specified size, in MiBs, before delivering it to the destination.
# Allowed value range: [1, 128]
kdf_buffer_size=1
# A prefix that Kinesis Data Firehose evaluates and adds to records before writing them to S3.
kdf_s3_prefix='aws'
# Enable AWS Kinesis Agent or not. Allowed values are: true, false.
aka_enable="true"

echo "config.sh imported."
