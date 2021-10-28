#!/bin/bash

# Kinesis Data Stream Consumer docker image generator.
# Copyright (c) 2021 AWS. All Rights Reserved.
# Created by Xin Zhang <cowcoa@gmail.com>

source ../bootstrapping/config.sh

# Variables
SHELL_PATH=$(cd "$(dirname "$0")";pwd)

echo "Build docker image..."
docker build -t $ecr_lambda_consumer_repo .

echo "Upload docker image to ECR..."
DOCKER_LOGIN_CMD=$(aws ecr get-login --no-include-email --region $deployment_region)
eval "${DOCKER_LOGIN_CMD}"
docker tag $ecr_lambda_consumer_repo:latest $account_id.dkr.ecr.$deployment_region.amazonaws.com/$ecr_lambda_consumer_repo:latest
docker push $account_id.dkr.ecr.$deployment_region.amazonaws.com/$ecr_lambda_consumer_repo:latest

echo
echo "Done"
