#!/bin/bash

# Kinesis Data Stream Consumer docker image generator.
# Copyright (c) 2021 AWS. All Rights Reserved.
# Created by Xin Zhang <cowcoa@gmail.com>

source ../../bootstrapping/config.sh

# Variables
SHELL_PATH=$(cd "$(dirname "$0")";pwd)

echo "Build docker image..."
docker build -t $lambda_consumer_ecr_repo .

echo "Upload docker image to ECR..."
DOCKER_LOGIN_CMD=$(aws ecr get-login --no-include-email --region $deployment_region)
eval "${DOCKER_LOGIN_CMD}"
docker tag $lambda_consumer_ecr_repo:latest $lambda_consumer_ecr_repo_uri:latest
docker push $lambda_consumer_ecr_repo_uri:latest

echo
echo "Done"
