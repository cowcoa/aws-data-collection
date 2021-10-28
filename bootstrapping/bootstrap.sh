#!/bin/bash
# Bootstrapping script for RG's Data Records Collection PoC.

# Import global variables.
source config.sh

# Create deployment s3 bucket if no such bucket.
if aws s3 ls "s3://$s3_bucket_deployment" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "Creating deployment s3 bucket $s3_bucket_deployment"
    aws s3api create-bucket --bucket $s3_bucket_deployment --region $deployment_region --create-bucket-configuration LocationConstraint=$deployment_region
    aws s3api put-public-access-block \
            --bucket $s3_bucket_deployment \
            --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
    aws s3api put-bucket-lifecycle --bucket $s3_bucket_deployment --lifecycle-configuration \
            '
            {
                "Rules": [
                {
                    "Expiration": {
                        "Days": 1
                    },
                    "Prefix": "",
                    "ID": "DayOne",
                    "Status": "Enabled"
                }
                ]
            }
            '
fi

# Create image builder ec2 instance role
if aws iam get-role --role-name "$image_builder_ec2_role" 2>&1 | grep -q 'NoSuchEntity'; then
    echo "Creating IAM role $image_builder_ec2_role"
    aws iam create-role --role-name "$image_builder_ec2_role" --assume-role-policy-document file://"image-builder-role-trust-policy.json"
fi
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore --role-name "$image_builder_ec2_role"
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds --role-name "$image_builder_ec2_role"
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder --role-name "$image_builder_ec2_role"
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --role-name "$image_builder_ec2_role"
