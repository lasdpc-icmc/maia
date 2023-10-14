#!/bin/bash
set -e

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change the current directory to the script's directory
cd "$SCRIPT_DIR"

PROFILE_NAME="aws-mock"
REGION="us-east-1"
CONFIG_FILE="$HOME/.aws/config"
PORT=4566
ENDPOINT_URL="http://localhost:4566"
AWS_PATH="../../../infrastructure/terraform/aws"

# Check and stop existing AWS Mock container
if docker ps -a --format '{{.Names}}' | grep -q "^aws_mock$"; then
    echo "Stopping and removing existing 'aws_mock' container..."
    docker stop aws_mock
    docker rm aws_mock
fi

# Add AWS Mock profile to AWS config file
if ! grep -q "\[profile $PROFILE_NAME\]" "$CONFIG_FILE"; then
    cat <<EOL >> "$CONFIG_FILE"
[profile $PROFILE_NAME]
endpoint_url = $ENDPOINT_URL
region = $REGION
aws_access_key_id = test
aws_secret_access_key = test
EOL
    echo "Profile '$PROFILE_NAME' added to '$CONFIG_FILE' with endpoint URL '$ENDPOINT_URL' and region '$REGION'."
else
    echo "Profile '$PROFILE_NAME' already exists in '$CONFIG_FILE'. Skipping."
fi

export AWS_PROFILE=$PROFILE_NAME

# Start AWS Mock container
docker run -d -p 4566:4566 --name aws_mock --memory 2g --cpus 1 localstack/localstack &> /dev/null || true

# Deploy S3 Buckets
cd "$AWS_PATH/s3"
tflocal init
tflocal workspace new aws-mock &> /dev/null || true
tflocal workspace select aws-mock
tflocal apply -var-file=vars/dev.tfvars -auto-approve

# Deploy VPC
cd "$SCRIPT_DIR"
cd "$AWS_PATH/network"
tflocal init 
tflocal workspace new aws-mock &> /dev/null || true
tflocal workspace select aws-mock
tflocal apply -var-file=vars/dev.tfvars -auto-approve

# Check for successful completion
if [ $? -eq 0 ]; then
    echo "Script successfully executed"
else
    echo "Error running the Script"
    exit 1
fi
