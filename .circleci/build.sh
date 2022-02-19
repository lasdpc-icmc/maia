#!/bin/bash
set -xe
source ./.circleci/common.sh;

# Load common functions and Install dependencies
env_vars

# Set Docker Credentiais

# echo $GCLOUD_SERVICE_KEY | base64 --decode --ignore-garbage > gcloud-service-key.json
# gcloud auth activate-service-account --key-file gcloud-service-key.json
# gcloud --quiet auth configure-docker

# Build Docker Image

docker build -t diegopedroso/$APP:$TAG -f apps/$APP/Dockerfile apps/$APP

# Push Docker Image
docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
docker push diegopedroso/$APP:$TAG