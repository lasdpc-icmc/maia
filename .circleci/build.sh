#!/bin/bash
set -xe
source ./.circleci/common.sh;

# Load common functions and Install dependencies

env_vars

# Build Docker Image

docker build -t diegopedroso/$APP:$TAG -f apps/$APP/Dockerfile apps/$APP

# Push Docker Image
docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
docker push diegopedroso/$APP:$TAG