import requests
import json
import time
import os
from datetime import timedelta

LOKI_URL = os.environ["LOKI_URL"]
APP_NAME = os.environ["APP_NAME"]
AWS_ACCESS_KEY_ID = os.environ["AWS_ACCESS_KEY_ID"]
AWS_SECRET_ACCESS_KEY = os.environ["AWS_SECRET_ACCESS_KEY"]
LOKI_BATCH_SIZE = int(os.environ["LOKI_BATCH_SIZE"])

def get_loki_logs(timestamp):
    end_time = timestamp + timedelta(minutes=LOKI_BATCH_SIZE)
    start_time = timestamp

    query = '{namespace ="' + APP_NAME + '"}'

    params = {
        "query": query,
        "start": int(start_time.timestamp()),
        "end": int(end_time.timestamp()),
        "limit": 10000
    }

    headers = {
        "Content-Type": "application/json"
    }

    response = requests.get(LOKI_URL + "/loki/api/v1/query_range", params=params,
                            headers=headers, auth=(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY))

    if response.status_code != 200:
        print("Error fetching logs from Loki API. Status code: ",
              response.status_code)
        print(response.content)
        exit(-1)

    base_folder_name = f"{APP_NAME}_logs"
    os.makedirs(base_folder_name, exist_ok=True)

    raw_logs = response.json()["data"]["result"]

    # Check if raw_logs is not empty
    if raw_logs and any(log["values"] for log in raw_logs):
        file_name = os.path.join(base_folder_name, f"{APP_NAME}_{timestamp}.txt")
        with open(file_name, "w") as f:
            for log in raw_logs:
                stream = log["stream"]
                log_entries = log["values"]
                for entry in log_entries:
                    entry_timestamp = entry[0]
                    message = entry[1]
                    parsed_log = json.loads(message)
                    f.write(f"{stream} {entry_timestamp} {parsed_log}\n")
        return file_name
    else:
        print(f"No logs found for timestamp {timestamp}. Skipping file creation.")
        return None
