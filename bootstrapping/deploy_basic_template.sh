#!/bin/bash
# Deploy/Update project on AWS by CloudFormation.

source bootstrap.sh

arg_count=$#
script_name=$(basename $0)
stack_action=update

input_template_file="basic_template.yaml"
output_template_file="packaged-template-output.yaml"

cf_stack_name="$project_name-basic"
cf_change_set_name="$cf_stack_name-change-set"

if test $arg_count -eq 1; then
  if [[ $1 =~ ^(create|update)$ ]]; then
    stack_action=$1
  else
    echo "Stack Action must be create or update"
    echo "Usage: $script_name [create|update]"
    exit -1
  fi
else
  echo "Usage: $script_name [create|update]"
  echo ""
  echo "Examples:"
  echo "$script_name create"
  echo ""
  exit 0
fi

echo "${stack_action^^} $cf_stack_name cloudformation stack..."
if [ $stack_action = update ]; then
  echo "NOTE: Before UPDATE a stack, be sure you already have the corresponding stack in cloudformation"
fi

if [ -f $output_template_file ]; then
  rm -rf $output_template_file
fi

echo "Packaging..."
aws cloudformation package \
  --template-file $input_template_file \
  --s3-bucket $deployment_bucket \
  --output-template-file $output_template_file

result=$?

if test $result -ne 0; then
  echo "Failed to package template $input_template_file"
  exit $result
fi

echo "Uploading template file..."
aws s3api put-object \
  --bucket $deployment_bucket \
  --key $output_template_file \
  --body $output_template_file

# Check S3 data records bucket existance.
should_create_bucket="false"
if aws s3 ls "s3://$data_records_bucket" 2>&1 | grep -q 'NoSuchBucket'; then
  should_create_bucket="true"
fi
echo "Should create s3 data records bucket: $should_create_bucket"

# Check ECR repository existance.
should_create_repository="false"
aws ecr describe-repositories --repository-names $lambda_consumer_ecr_repo > /dev/null 2>&1
result=$?
if [[ ! "${result}" -eq 0 ]]; then
    should_create_repository="true"
fi
echo "Should create ecr lambda consumer image repository: $should_create_repository"

echo "Creating change set..."
aws cloudformation create-change-set \
  --change-set-type ${stack_action^^} \
  --stack-name $cf_stack_name \
  --change-set-name $cf_change_set_name \
  --template-url https://$deployment_bucket.s3.$deployment_region.amazonaws.com/$output_template_file \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --parameters ParameterKey="Prefix",ParameterValue=$project_name \
               ParameterKey="BucketName",ParameterValue=$data_records_bucket \
               ParameterKey="ShouldCreateBucket",ParameterValue=$should_create_bucket \
               ParameterKey="RepositoryName",ParameterValue=$lambda_consumer_ecr_repo \
               ParameterKey="ShouldCreateRepository",ParameterValue=$should_create_repository

result=$?

if test $result -ne 0; then
  echo "Failed to create change set $cf_change_set_name"
  if [ -f $output_template_file ]; then
    rm -rf $output_template_file
  fi
	exit $result
fi

echo "Waiting for change-set-create-complete..."
aws cloudformation wait \
  change-set-create-complete \
  --stack-name $cf_stack_name \
  --change-set-name $cf_change_set_name
    
result=$?

if test $result -ne 0; then
  echo "create-change-set return failed"
  if [ -f $output_template_file ]; then
    rm -rf $output_template_file
  fi
	exit $result
fi

echo "Executing change set..."
aws cloudformation execute-change-set \
  --change-set-name $cf_change_set_name \
  --stack-name $cf_stack_name

echo "Waiting for stack executing complete..."
aws cloudformation wait \
  stack-${stack_action}-complete \
  --stack-name $cf_stack_name

result=$?

if test $result -ne 0; then
  echo "Deleting change set..."
  aws cloudformation delete-change-set \
    --stack-name $cf_stack_name \
    --change-set-name $cf_change_set_name
fi

if [ -f $output_template_file ]; then
	rm -rf $output_template_file
fi

echo "done"