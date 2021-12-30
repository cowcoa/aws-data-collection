#!/bin/bash
# Bootstrapping script for Data Records Collection PoC.

# Get script location.
SHELL_PATH=$(cd "$(dirname "$0")";pwd)
# Import global variables.
source $SHELL_PATH/config.sh

# If bucket name is already occupied by another user, CLI 'aws s3 ls' will report 'Access Denied'.
if aws s3 ls "s3://$s3_deployment_bucket" 2>&1 | grep -q 'Access Denied'; then
  echo "Bucket $s3_deployment_bucket already exists, please change bucket name."
  exit -1
fi

# Create deployment s3 bucket if no such bucket.
if aws s3 ls "s3://$s3_deployment_bucket" 2>&1 | grep -q 'NoSuchBucket'; then
  echo "Creating deployment s3 bucket $s3_deployment_bucket"
  if [ $deployment_region = us-east-1 ]; then
    aws s3api create-bucket --bucket $s3_deployment_bucket --region $deployment_region
  else
    aws s3api create-bucket --bucket $s3_deployment_bucket --region $deployment_region --create-bucket-configuration LocationConstraint=$deployment_region
  fi
 
  aws s3api put-public-access-block \
    --bucket $s3_deployment_bucket \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
  aws s3api put-bucket-lifecycle --bucket $s3_deployment_bucket --lifecycle-configuration \
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

echo 'bootstrapping done.'
