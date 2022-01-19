#!/bin/bash

# Get script location.
SHELL_PATH=$(cd "$(dirname "$0")";pwd)
# Import global variables.
source $SHELL_PATH/../../../bootstrapping/config.sh

# Generate AWSTOE component document from template.
awstoe_template_file="$SHELL_PATH/install-nginx-aka.yaml"
sed "s/MACRO_DEPLOYMENT_BUCKET/$s3_deployment_bucket/g" ${awstoe_template_file}.template > $awstoe_template_file

# Generate Kinesis Agent config file from template.
aka_config_template_file="$SHELL_PATH/kinesis-agent.json"
sed "s/MACRO_DEPLOYMENT_REGION/$deployment_region/g; s/MACRO_KINESIS_STREAM_NAME/$fb_kinesis_stream/g" ${aka_config_template_file}.template > $aka_config_template_file

# Generate nginx config file from template.
nginx_config_template_file="$SHELL_PATH/nginx.conf"
sed "s/MACRO_NGINX_HTTP_PORT/$ec2_http_port/g" ${nginx_config_template_file}.template > $nginx_config_template_file

# Upload Kinesis Agent config file
aws s3 cp "$SHELL_PATH/kinesis-agent.json" "s3://$s3_deployment_bucket/image-builder/components/nginx-aka/kinesis-agent.json"
# Update nginx config file
aws s3 cp "$SHELL_PATH/nginx.conf" "s3://$s3_deployment_bucket/image-builder/components/nginx-aka/nginx.conf"
# Update logrotate config file
aws s3 cp "$SHELL_PATH/nginx-logrotate.conf" "s3://$s3_deployment_bucket/image-builder/components/nginx-aka/nginx-logrotate.conf"
# Update crond config file
aws s3 cp "$SHELL_PATH/nginx-logrotate-crond.conf" "s3://$s3_deployment_bucket/image-builder/components/nginx-aka/nginx-logrotate-crond.conf"
# Upload components document.
aws s3 cp "$SHELL_PATH/install-nginx-aka.yaml" "s3://$s3_deployment_bucket/image-builder/components/install-nginx-aka.yaml"

echo "AWSTOE components deployment done."
