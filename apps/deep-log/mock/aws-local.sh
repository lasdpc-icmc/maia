#!/bin/bash
set -e

# Configuration
PROFILE_NAME="aws-mock"
REGION="us-east-1"
CONFIG_FILE="$HOME/.aws/config"
PORT=4566
ENDPOINT_URL="http://localhost:4566"
AWS_PATH="../../../infrastructure/terraform/aws"
AWS_ACCESS_KEY="test"
AWS_SECRET_KEY="test"

# Function to check and stop existing AWS Mock container
stop_existing_aws_mock_container() {
    if docker ps -a --format '{{.Names}}' | grep -q "^aws_mock$"; then
        echo "Stopping and removing existing 'aws_mock' container..."
        docker stop aws_mock
        docker rm aws_mock
    fi
}

# Function to add AWS Mock profile to AWS config file
add_aws_mock_profile() {
    if ! grep -q "\[profile $PROFILE_NAME\]" "$CONFIG_FILE"; then
        cat <<EOL >> "$CONFIG_FILE"
[profile $PROFILE_NAME]
endpoint_url = $ENDPOINT_URL
region = $REGION
aws_access_key_id = $AWS_ACCESS_KEY
aws_secret_access_key = $AWS_SECRET_KEY
EOL
        echo "Profile '$PROFILE_NAME' added to '$CONFIG_FILE' with endpoint URL '$ENDPOINT_URL' and region '$REGION'."
    else
        echo "Profile '$PROFILE_NAME' already exists in '$CONFIG_FILE'. Skipping."
    fi
}

# Function to start the AWS Mock container
start_aws_mock_container() {
    docker run -d -p 4566:4566 --name aws_mock --memory 2g --cpus 1 localstack/localstack &> /dev/null || true
}

# Function to deploy Terraform stack
deploy_terraform_stack() {
    local tf_directory="$1"
    local tf_vars_file="$2"

    cd "$tf_directory"
    tflocal init
    tflocal workspace new aws-mock &> /dev/null || true
    tflocal workspace select aws-mock
    tflocal apply -var-file="$tf_vars_file" -auto-approve
}

# Main Script

# Stop existing AWS Mock container
stop_existing_aws_mock_container

# Add AWS Mock profile to AWS config file
add_aws_mock_profile

# Start AWS Mock container
start_aws_mock_container

# Deploy S3 Buckets
deploy_terraform_stack "$AWS_PATH/s3" "$AWS_PATH/s3/vars/dev.tfvars"

# Deploy VPC
deploy_terraform_stack "$AWS_PATH/network" "$AWS_PATH/network/vars/dev.tfvars"

# Check for successful completion
if [ $? -eq 0 ]; then
    echo "Script successfully executed"
else
    echo "Error running the Script"
    exit 1
fi
