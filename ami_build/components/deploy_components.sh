#!/bin/bash

# Import global variables.
source ../../bootstrapping/config.sh

# Generate AWSTOE component document from template.
awstoe_template_file="fluentbit/install-fluentbit.yaml"
sed "s/MACRO_DEPLOYMENT_BUCKET/$deployment_bucket/g" ${awstoe_template_file}.template > $awstoe_template_file
# Generate fluent-bit env file from template.
fluentbit_env_template_file="fluentbit/td-agent-bit.env"
sed "s/MACRO_FLUENTBIT_HTTP_PORT/$fluentbit_http_port/g; s/MACRO_FLUENTBIT_AWS_REGION/$deployment_region/g; s/MACRO_FLUENTBIT_KINESIS_STREAM/$fluentbit_kinesis_stream/g" ${fluentbit_env_template_file}.template > $fluentbit_env_template_file


# Upload fluent-bit repo file
aws s3 cp fluentbit/td-agent-bit.repo "s3://$deployment_bucket/image-builder/components/fluentbit/td-agent-bit.repo"
# Upload fluent-bit config file
aws s3 cp fluentbit/td-agent-bit.conf "s3://$deployment_bucket/image-builder/components/fluentbit/td-agent-bit.conf"
# Update fluent-bit env file
aws s3 cp fluentbit/td-agent-bit.env "s3://$deployment_bucket/image-builder/components/fluentbit/td-agent-bit.env"
# Upload components document.
aws s3 cp fluentbit/install-fluentbit.yaml "s3://$deployment_bucket/image-builder/components/install-fluentbit.yaml"


echo "done"