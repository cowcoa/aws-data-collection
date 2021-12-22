#!/bin/bash

# Get script location.
SHELL_PATH=$(cd "$(dirname "$0")";pwd)
# Import global variables.
source $SHELL_PATH/../../../bootstrapping/config.sh

# Generate AWSTOE component document from template.
awstoe_template_file="$SHELL_PATH/install-nginx-fluentbit.yaml"
sed "s/MACRO_DEPLOYMENT_BUCKET/$s3_deployment_bucket/g" ${awstoe_template_file}.template > $awstoe_template_file

# Generate fluent-bit config file from template.
fluentbit_config_template_file="$SHELL_PATH/td-agent-bit.conf"
sed "s/MACRO_FLUENTBIT_OUTPUT_AWS_REGION/$deployment_region/g; s/MACRO_FLUENTBIT_OUTPUT_KINESIS_STREAM/$fb_kinesis_stream/g; s/MACRO_FLUENTBIT_LOG_LEVEL/$fb_log_level/g" ${fluentbit_config_template_file}.template > $fluentbit_config_template_file

# Generate nginx config file from template.
nginx_config_template_file="$SHELL_PATH/nginx.conf"
sed "s/MACRO_NGINX_HTTP_PORT/$ec2_http_port/g" ${nginx_config_template_file}.template > $nginx_config_template_file

# Upload fluent-bit repo file
aws s3 cp "$SHELL_PATH/td-agent-bit.repo" "s3://$s3_deployment_bucket/image-builder/components/nginx-fluentbit/td-agent-bit.repo"
# Upload fluent-bit config file
aws s3 cp "$SHELL_PATH/td-agent-bit.conf" "s3://$s3_deployment_bucket/image-builder/components/nginx-fluentbit/td-agent-bit.conf"
# Update nginx config file
aws s3 cp "$SHELL_PATH/nginx.conf" "s3://$s3_deployment_bucket/image-builder/components/nginx-fluentbit/nginx.conf"
# Update logrotate config file
aws s3 cp "$SHELL_PATH/nginx-logrotate.conf" "s3://$s3_deployment_bucket/image-builder/components/nginx-fluentbit/nginx-logrotate.conf"
# Update crond config file
aws s3 cp "$SHELL_PATH/nginx-logrotate-crond.conf" "s3://$s3_deployment_bucket/image-builder/components/nginx-fluentbit/nginx-logrotate-crond.conf"
# Upload components document.
aws s3 cp "$SHELL_PATH/install-nginx-fluentbit.yaml" "s3://$s3_deployment_bucket/image-builder/components/install-nginx-fluentbit.yaml"

echo "AWSTOE components deployment done."