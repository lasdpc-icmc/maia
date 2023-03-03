import boto3
import os
import requests
import json
import time
import aws_tools

# Define environment variables
LOKI_URL = os.environ['LOKI_URL']
APP_NAME = os.environ['APP_NAME']
TIME_RANGE = int(os.environ['TIME_RANGE'])
AWS_ACCESS_KEY_ID = os.environ['AWS_ACCESS_KEY_ID']
AWS_SECRET_ACCESS_KEY = os.environ['AWS_SECRET_ACCESS_KEY']
AWS_REGION = os.environ['AWS_REGION']
S3_BUCKET_NAME = os.environ['S3_BUCKET_NAME']

# Define time range for the logs
end_time = int(time.time())  # current time in seconds
start_time = end_time - TIME_RANGE  # TIME_RANGE seconds ago
global file_name
# Define the query for the logs
query = '{namespace="' + APP_NAME + '"}'

# Define the parameters for the query
params = {
    "query": query,
    "start": start_time,
    "end": end_time
}

# Define the headers for the request
headers = {
    "Content-Type": "application/json"
}

# Send the request to the Loki API to fetch logs
response = requests.get(LOKI_URL + "/loki/api/v1/query_range", params=params, headers=headers)

# Check if the request was successful
if response.status_code == 200:
    # Get the raw logs from the response
    raw_logs = response.json()["data"]["result"]
    
    # Create a file to store the logs
    file_name = f"{APP_NAME}_{int(time.time())}.txt"
    with open(file_name, "w") as f:
        # Parse and write each log entry to the file
        for log in raw_logs:
            stream = log["stream"]
            log_entries = log["values"]
            for entry in log_entries:
                timestamp = entry[0]
                message = entry[1]
                parsed_log = json.loads(message)
                f.write(f"{stream} {timestamp} {parsed_log}\n")
    
    # Upload the file to S3

    s3_path = "raw"
    aws_tools.upload_to_s3(file_name, s3_path)
    
else:
    # Print the error message and content if the request failed
    print("Error fetching logs from Loki API. Status code: ", response.status_code)
    print(response.content)