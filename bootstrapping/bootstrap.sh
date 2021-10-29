#!/bin/bash
# Bootstrapping script for Data Records Collection PoC.

# Import global variables.
source config.sh

# Create deployment s3 bucket if no such bucket.
if aws s3 ls "s3://$deployment_bucket" 2>&1 | grep -q 'NoSuchBucket'; then
  echo "Creating deployment s3 bucket $deployment_bucket"
  aws s3api create-bucket --bucket $deployment_bucket --region $deployment_region --create-bucket-configuration LocationConstraint=$deployment_region
  aws s3api put-public-access-block \
    --bucket $deployment_bucket \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
  aws s3api put-bucket-lifecycle --bucket $deployment_bucket --lifecycle-configuration \
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

echo 'done'