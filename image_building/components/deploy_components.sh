#!/bin/bash

# Import global variables.
source ../../bootstrapping/config.sh

# Upload fluent-bit repo file
aws s3 cp fluentbit/td-agent-bit.repo "s3://$s3_bucket_deployment/image-builder/components/fluentbit/td-agent-bit.repo"
# Upload fluent-bit config file
aws s3 cp fluentbit/td-agent-bit.conf "s3://$s3_bucket_deployment/image-builder/components/fluentbit/td-agent-bit.conf"
# Upload components document.
aws s3 cp install-fluentbit.yaml "s3://$s3_bucket_deployment/image-builder/components/install-fluentbit.yaml"
# Deploy components.
component_name="install-fluentbit"
component_version="1.0.20"
component_arn=""
component_list="$(aws imagebuilder list-components --filters name='name',values="$component_name" \
    --output json \
    --query 'componentVersionList')"

for row in $(echo "${component_list}" | jq -r '.[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }
    
    if [ "$(_jq '.version')" = "$component_version" ]; then
        component_arn="$(_jq '.arn')"
    fi
done

echo "$component_arn"

if [ -z "$component_arn" ]; then
    echo "okok"
    component_arn="$(aws imagebuilder create-component \
        --name 'install-fluentbit' \
        --semantic-version "$component_version" \
        --platform 'Linux' \
        --uri s3://rg-data-stream-deployment-us-west-2/image-builder/components/install-fluentbit.yaml \
        --description 'Install fluent-bit.' \
        --change-description 'Initial version.' \
        --output text \
        --query 'componentBuildVersionArn')"
fi

echo "$component_arn"
printf '[{"componentArn":"%s"}]\n' "$component_arn" > component_arn.json