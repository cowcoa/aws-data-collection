#!/bin/bash
# Bootstrapping script for RG's PoC.

# Import global variables.
source ../../bootstrapping/config.sh

# Deploy components.
recipe_name="fluentbit"
recipe_version="1.0.8"
recipe_arn=""
recipe_list="$(aws imagebuilder list-image-recipes --owner Self --filters name='name',values="$recipe_name" \
    --output json \
    --query 'imageRecipeSummaryList')"
echo $recipe_list

for row in $(echo "${recipe_list}" | jq -r '.[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }
    
    version=$(basename $(_jq '.arn'))
    echo $version
    if [ "$(basename $(_jq '.arn'))" = "$recipe_version" ]; then
        recipe_arn="$(_jq '.arn')"
    fi
done

echo "$recipe_arn"

parent_image="$(aws ssm get-parameters \
  --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 \
  --output text \
  --query 'Parameters[0].[Value]')"
  
echo "parent image: $parent_image"

if [ -z "$recipe_arn" ]; then
    echo "okok"
    recipe_arn="$(aws imagebuilder create-image-recipe \
      --name $recipe_name \
      --semantic-version $recipe_version \
      --parent-image $parent_image \
      --components file://../components/component_arn.json \
      --description 'Fluentbit install recipe.' \
      --additional-instance-configuration '{"systemsManagerAgent":{"uninstallAfterBuild":true}}' \
      --output text \
      --query 'imageRecipeArn')"
fi
echo "$recipe_arn"