import boto3
import os
import requests
import json
import time
import aws_tools
global file_name


def get_loki_logs(LOKI_URL, APP_NAME, TIME_RANGE, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION, S3_BUCKET_NAME):
    end_time = int(time.time())
    start_time = end_time - TIME_RANGE  # TIME_RANGE seconds ago
    query = '{namespace ="' + APP_NAME + '"}'

    params = {
        "query": query,
        "start": start_time,
        "end": end_time,
        "limit": 5000,
        "batch": 5000,
        "direction": "forward"
    }

    headers = {
        "Content-Type": "application/json"
    }

    response = requests.get(LOKI_URL + "/loki/api/v1/query_range", params=params,
                            headers=headers, auth=(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY))

    if response.status_code == 200:
        raw_logs = response.json()["data"]["result"]
        file_name = f"{APP_NAME}_{int(time.time())}.txt"
        with open(file_name, "w") as f:

            for log in raw_logs:
                stream = log["stream"]
                log_entries = log["values"]
                for entry in log_entries:
                    timestamp = entry[0]
                    message = entry[1]
                    parsed_log = json.loads(message)
                    f.write(f"{stream} {timestamp} {parsed_log}\n")

        return file_name

    else:
        print("Error fetching logs from Loki API. Status code: ",
              response.status_code)
        print(response.content)
