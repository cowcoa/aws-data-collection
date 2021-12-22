#!/bin/bash

# Get script location.
SHELL_PATH=$(cd "$(dirname "$0")";pwd)
# Import global variables.
source $SHELL_PATH/../../../bootstrapping/config.sh

# Generate AWSTOE component document from template.
awstoe_template_file="$SHELL_PATH/install-fluentbit.yaml"
sed "s/MACRO_DEPLOYMENT_BUCKET/$s3_deployment_bucket/g" ${awstoe_template_file}.template > $awstoe_template_file
# Generate fluent-bit env file from template.
fluentbit_env_template_file="$SHELL_PATH/td-agent-bit.env"
sed "s/MACRO_FLUENTBIT_HTTP_PORT/$ec2_http_port/g; s/MACRO_FLUENTBIT_AWS_REGION/$deployment_region/g; s/MACRO_FLUENTBIT_KINESIS_STREAM/$fb_kinesis_stream/g; s/MACRO_FLUENTBIT_LOG_LEVEL/$fb_log_level/g" ${fluentbit_env_template_file}.template > $fluentbit_env_template_file

# Upload fluent-bit repo file
aws s3 cp "$SHELL_PATH/td-agent-bit.repo" "s3://$s3_deployment_bucket/image-builder/components/fluentbit/td-agent-bit.repo"
# Upload fluent-bit config file
aws s3 cp "$SHELL_PATH/td-agent-bit.conf" "s3://$s3_deployment_bucket/image-builder/components/fluentbit/td-agent-bit.conf"
# Update fluent-bit env file
aws s3 cp "$SHELL_PATH/td-agent-bit.env" "s3://$s3_deployment_bucket/image-builder/components/fluentbit/td-agent-bit.env"
# Upload components document.
aws s3 cp "$SHELL_PATH/install-fluentbit.yaml" "s3://$s3_deployment_bucket/image-builder/components/install-fluentbit.yaml"

echo "AWSTOE components deployment done."