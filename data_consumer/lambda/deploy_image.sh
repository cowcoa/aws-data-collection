#!/bin/bash

# Kinesis Data Stream Consumer docker image generator.
# Copyright (c) 2021 AWS. All Rights Reserved.
# Created by Xin Zhang <cowcoa@gmail.com>

# Get script location.
SHELL_PATH=$(cd "$(dirname "$0")";pwd)
# Import global variables
source $SHELL_PATH/../../bootstrapping/config.sh

echo "Build docker image..."
docker build -t $ecr_lambda_consumer_repo $SHELL_PATH

image_tag="$(echo $(date '+%Y.%m.%d.%H%M%S' -d '+8 hours'))"
#image_tag="$(printf '%(%Y.%m.%d)T\n' -1)"

echo "ecr_lambda_consumer_repo: $ecr_lambda_consumer_repo"
echo "ecr_lambda_consumer_repo_uri: $ecr_lambda_consumer_repo_uri"

echo "Upload docker image to ECR..."
DOCKER_LOGIN_CMD=$(aws ecr get-login --no-include-email --region $deployment_region)
eval "${DOCKER_LOGIN_CMD}"
docker tag $ecr_lambda_consumer_repo:latest $ecr_lambda_consumer_repo_uri:$image_tag
docker push $ecr_lambda_consumer_repo_uri:$image_tag
docker tag $ecr_lambda_consumer_repo:latest $ecr_lambda_consumer_repo_uri:latest
docker push $ecr_lambda_consumer_repo_uri:latest

echo
echo "Done"
