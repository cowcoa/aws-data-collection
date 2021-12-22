#!/bin/bash
# Deploy/Update project on AWS by CloudFormation.

arg_count=$#
script_name=$(basename $0)
stack_action=update

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

# Get script location.
SHELL_PATH=$(cd "$(dirname "$0")";pwd)
# Execute components deployment first.
$SHELL_PATH/components/fluentbit/deploy_components.sh
$SHELL_PATH/components/nginx_fluentbit/deploy_components.sh
# Import global variables
source $SHELL_PATH/../bootstrapping/config.sh

input_template_file="$SHELL_PATH/image_pipeline_template.yaml"
output_template_file_name="packaged-template-output.yaml"
output_template_file="$SHELL_PATH/$output_template_file_name"

cf_stack_name="$project_name-image-pipeline"
cf_change_set_name="$cf_stack_name-change-set"

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
  --s3-bucket $s3_deployment_bucket \
  --output-template-file $output_template_file

result=$?

if test $result -ne 0; then
  echo "Failed to package template $input_template_file"
  exit $result
fi

echo "Uploading template file..."
aws s3api put-object \
  --bucket $s3_deployment_bucket \
  --key $output_template_file_name \
  --body $output_template_file
  
# Image Builder component doc uri.
component_doc_uri=""
if [ nginx_enable = false ]; then
  component_doc_uri="s3://$s3_deployment_bucket/image-builder/components/install-fluentbit.yaml"
else
  component_doc_uri="s3://$s3_deployment_bucket/image-builder/components/install-nginx-fluentbit.yaml"
fi

echo "Creating change set..."
aws cloudformation create-change-set \
  --change-set-type ${stack_action^^} \
  --stack-name $cf_stack_name \
  --change-set-name $cf_change_set_name \
  --template-url https://$s3_deployment_bucket.s3.$deployment_region.amazonaws.com/$output_template_file_name \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --parameters ParameterKey="Prefix",ParameterValue=$project_name \
               ParameterKey="BasicStack",ParameterValue="$project_name-basic" \
               ParameterKey="DeploymentBucket",ParameterValue=$s3_deployment_bucket \
               ParameterKey="ComponentDocUri",ParameterValue=$component_doc_uri \
               ParameterKey="ComponentVersion",ParameterValue=$ib_component_version \
               ParameterKey="ImageRecipeParentAmiId",ParameterValue=$ib_amz_linux_2_ami \
               ParameterKey="ImageRecipeVersion",ParameterValue=$ib_image_recipe_version \
               ParameterKey="FluentBitLogLevel",ParameterValue=$fb_log_level \
               ParameterKey="EnableNginx",ParameterValue=$nginx_enable \
               ParameterKey="EC2InstanceType",ParameterValue=$ec2_instance_type \
               ParameterKey="EC2HttpPort",ParameterValue=$ec2_http_port \
               ParameterKey="EC2InstanceKeyPair",ParameterValue=$ec2_instance_key_pair \
               ParameterKey="AsgMinCapacity",ParameterValue=$asg_min_capacity \
               ParameterKey="AsgMaxCapacity",ParameterValue=$asg_max_capacity \
               ParameterKey="AsgDesiredCapacity",ParameterValue=$asg_desired_capacity \
               ParameterKey="ElbType",ParameterValue=$elb_type

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

result=$?

if test $result -ne 0; then
  echo "Failed to execute change set $cf_change_set_name"
  aws cloudformation delete-change-set \
    --stack-name $cf_stack_name \
    --change-set-name $cf_change_set_name
else
  echo "It's a long-running deployment(about 30 minutes for building AMI), please check the stack status from console..."
fi

if [ -f $output_template_file ]; then
	rm -rf $output_template_file
fi

echo "done"
