import os
import boto3
import requests
import time

# Set general variables
Bucket = os.environ['BUCKET_NAME']
Key = os.environ['KEY_NAME']
pushgateway_url = os.environ['PUSHGATEWAY_URL']
metrics_filename = "/tmp/locust.metrics"

# Get s3 client
client = boto3.client("s3")

while True:
    # Download file
    client.download_file(Bucket, Key, metrics_filename)

    # Get metrics data itself
    metrics_file = open(metrics_filename, "rb")
    metrics_data = metrics_file.read()
    metrics_file.close()

    response = requests.post(
        pushgateway_url + "/metrics/job/locust-metrics",
        data=metrics_data
    )

    if response.status_code >= 400:
        print("Error posting metrics")
        exit(-1)

    time.sleep(15)

