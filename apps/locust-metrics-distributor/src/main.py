import os
import boto3
import requests
import time

# Set general variables
bucket = os.environ['BUCKET_NAME']
key = os.environ['KEY_NAME']
pushgateway_url = os.environ['PUSHGATEWAY_URL']
metrics_filename = "/tmp/locust.metrics"

# Get S3 client
client = boto3.client("s3")

while True:
    try:
        # Download file from S3
        client.download_file(bucket, key, metrics_filename)
        print(f"Downloaded {key} from bucket {bucket}")

        # Read metrics data
        with open(metrics_filename, "rb") as metrics_file:
            metrics_data = metrics_file.read()

        # Post metrics to Pushgateway
        response = requests.post(
            f"{pushgateway_url}/metrics/job/locust-metrics",
            data=metrics_data,
            headers={"Content-Type": "text/plain"}
        )

        if response.status_code >= 400:
            print(f"Error posting metrics: {response.text}")
        else:
            print("Metrics posted successfully")

    except Exception as e:
        print(f"Error occurred: {e}")

    # Wait before the next iteration
    time.sleep(20)
