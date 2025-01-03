import os
import boto3
import requests
import time

BUCKET_NAME = os.environ.get('BUCKET_NAME', 'lasdpc-locust-results')
FILE_KEY = os.environ.get('KEY_NAME', 'sock-shop/locust.metrics')
PUSHGATEWAY_URL = os.environ.get('PUSHGATEWAY_URL', 'http://localhost:9091')

TEMP_FILE_PATH = "/tmp/metrics_file"

def download_file_from_s3(bucket, key, destination):
    """
    Download a file from an S3 bucket to a local destination.
    """
    s3 = boto3.client('s3')
    try:
        s3.download_file(bucket, key, destination)
        print(f"File downloaded from S3 bucket '{bucket}' with key '{key}' to '{destination}'.")
    except Exception as e:
        print(f"Error downloading file from S3: {e}")
        raise

def push_metrics_to_pushgateway(file_path, pushgateway_url):
    """
    Push metrics data to Prometheus Pushgateway.
    """
    try:
        with open(file_path, 'r') as metrics_file:
            metrics_data = metrics_file.read()
        
        response = requests.post(
            f"{pushgateway_url}/metrics/job/locust-metrics",
            data=metrics_data
        )
        
        if response.status_code >= 400:
            print(f"Error posting metrics: {response.status_code} - {response.text}")
            return False
        
        print("Metrics successfully posted to Pushgateway.")
        return True
    except Exception as e:
        print(f"Error pushing metrics to Pushgateway: {e}")
        raise

def main():
    while True:
        try:
            download_file_from_s3(BUCKET_NAME, FILE_KEY, TEMP_FILE_PATH)
            
            success = push_metrics_to_pushgateway(TEMP_FILE_PATH, PUSHGATEWAY_URL)
            
            if not success:
                print("Failed to push metrics. Exiting...")
                exit(-1)
        except Exception as e:
            print(f"An error occurred: {e}")
            exit(-1)
        
        time.sleep(20)

if __name__ == "__main__":
    main()
