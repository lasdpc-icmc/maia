#!/bin/bash
set -e

DIR_ORIGIN=$(pwd)
PROFILE_NAME="aws-mock"
REGION="us-east-1"
CONFIG_FILE="$HOME/.aws/config"
PORT=4566
ENDPOINT_URL="http://localhost:4566"
AWS_S3_PATH="../../../infrastructure/terraform/aws/s3"
AWS_S3_VPC="../../../infrastructure/terraform/aws/network"

# Setup the AWS local config file

if grep -q "\[profile $PROFILE_NAME\]" "$CONFIG_FILE"; then
  echo "Profile '$PROFILE_NAME' already exists in '$CONFIG_FILE'. Skipping."
else
  cat <<EOL >> "$CONFIG_FILE"

[profile $PROFILE_NAME]
endpoint_url = $ENDPOINT_URL
region = $REGION
aws_access_key_id = test
aws_secret_access_key = test
EOL

  echo "Profile '$PROFILE_NAME' added to '$CONFIG_FILE' with endpoint URL '$ENDPOINT_URL' and region '$REGION'."
fi

export AWS_PROFILE=$PROFILE_NAME

docker run -d -p 4566:4566 --name aws_mock --memory 2g --cpus 1 localstack/localstack &> /dev/null || true

cp -R $AWS_S3_PATH /tmp
rm /tmp/s3/config.tf
cd /tmp/s3/
tflocal init 
tflocal workspace new aws-mock &> /dev/null || true
tflocal workspace select aws-mock
tflocal apply -var-file=vars/prod.tfvars -auto-approve

cd $DIR_ORIGIN
cp -R $AWS_S3_VPC /tmp
rm /tmp/network/config.tf
cd /tmp/network/
tflocal init 
tflocal workspace new aws-mock &> /dev/null || true
tflocal workspace select aws-mock
tflocal apply -var-file=vars/prod.tfvars -auto-approve


# Check for successful completion

if [ $? -eq 0 ]; then
    echo "Script successfully executed"
else
    echo "Error running the Script"
    exit 1
fi