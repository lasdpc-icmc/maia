# AWS Mock Setup Script

This script automates the setup of a local AWS environment using AWS Mock (localstack) for development and testing purposes. It configures AWS CLI profiles, sets up a local stack  using Terraform.

## Prerequisites

Before running this script, ensure that you have the following prerequisites installed:

## Prerequisites

Before running this script, make sure you have the following prerequisites:

1. [Docker](https://www.docker.com/get-started) installed to run Localstack image.
2. [AWS CLI](https://aws.amazon.com/cli/) installed for AWS profile and S3 operations.
3. [tflocal](https://github.com/localstack/terraform-local) This package provides tflocal - a small wrapper script to run Terraform against LocalStack.

## Usage

### 1. Standard Mode

#### Step 1: Setup the aws-cli

```bash
chmod +x aws-mock.sh
source aws-mock.sh
```

The script configures an AWS profile named `aws-mock`. If the profile does not exist in your AWS CLI configuration, it will be added. This profile includes the following settings:


```bash
endpoint_url = http://localhost:4566
region = us-west-2
aws_access_key_id = test
aws_secret_access_key = test
```

#### Step 2: List Buckets

```bash
aws s3 ls --endpoint-url $ENDPOINT_URL
```

Where, ENDPOINT_URL=http://localhost:4566

#### Step 2: List VPC

```bash
aws ec2 describe-vpcs --endpoint-url $ENDPOINT_URL
```