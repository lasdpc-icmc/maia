import requests
import json
import time
import os
from datetime import datetime, timedelta

LOKI_URL = os.environ["LOKI_URL"]
APP_NAME = os.environ["APP_NAME"]
LOKI_BATCH_SIZE = int(os.environ["LOKI_BATCH_SIZE"])
LINES_PER_FILE = 10000
REQUEST_TIMEOUT = 600
MAX_RETRIES = 30
RETRY_DELAY = 5

def get_loki_logs(start_time):
    end_time = start_time + timedelta(minutes=LOKI_BATCH_SIZE)

    query = '{namespace ="' + APP_NAME + '"}'

    params = {
        "query": query,
        "start": int(start_time.timestamp() * 1e9),
        "end": int(end_time.timestamp() * 1e9),
        "limit": 5000
    }

    headers = {
        "Content-Type": "application/json"
    }

    retries = 0
    while retries < MAX_RETRIES:
        try:
            response = requests.get(
                LOKI_URL + "/loki/api/v1/query_range",
                params=params,
                headers=headers,
                timeout=REQUEST_TIMEOUT
            )

            response.raise_for_status()

            return response.json()["data"]["result"]

        except (requests.exceptions.Timeout, requests.exceptions.ConnectionError) as e:
            print(f"Request failed: {e}")
            retries += 1
            if retries < MAX_RETRIES:
                print(f"Retrying in {RETRY_DELAY} seconds...")
                time.sleep(RETRY_DELAY)
            else:
                print("Max retries exceeded. Exiting.")
                exit(-1)
        except requests.exceptions.HTTPError as e:
            print(f"HTTP error occurred: {e}")
            exit(-1)

def write_logs_to_file(logs, timestamp, file_index):
    base_folder_name = f"{APP_NAME}_logs"
    os.makedirs(base_folder_name, exist_ok=True)

    file_name = os.path.join(base_folder_name, f"{APP_NAME}_{timestamp}_{file_index}.txt")
    with open(file_name, "w") as f:
        for log in logs:
            stream = log["stream"]
            # Remove specified fields
            for field in ["namespace", "node_name", "pod", "filename", "job", "stream", "container"]:
                stream.pop(field, None)
            log_entries = log["values"]
            for entry in log_entries:
                entry_timestamp = entry[0]
                message = entry[1]
                f.write(f"{stream} {entry_timestamp} {message}\n")
    
    print(f"Written {len(logs)} streams to {file_name}")
    return file_name

def fetch_and_save_logs():
    end_time = datetime.utcnow()
    start_time = end_time - timedelta(days=15)
    current_time = start_time
    file_index = 0
    log_lines = []

    while current_time < end_time:
        logs = get_loki_logs(current_time)
        current_time += timedelta(minutes=LOKI_BATCH_SIZE)
        
        if logs:
            for log in logs:
                log_lines.extend(log["values"])
            
            if len(log_lines) >= LINES_PER_FILE:
                write_logs_to_file(logs, current_time, file_index)
                log_lines = []
                file_index += 1

    if log_lines:
        write_logs_to_file(log_lines, current_time, file_index)

if __name__ == "__main__":
    fetch_and_save_logs()
    print("Log fetching and writing completed.")