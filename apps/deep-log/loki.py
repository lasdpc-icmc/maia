import requests
import json
import time
import os
from datetime import timedelta, datetime, timezone

APP_NAME = "user"
LOKI_BATCH_SIZE = int(os.getenv("LOKI_BATCH_SIZE", 10))
LOKI_URL = os.getenv("LOKI_URL", "https://localhost:3100")
AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")

def get_loki_logs(timestamp):
    start_time = timestamp.astimezone(timezone.utc)
    end_time = (timestamp + timedelta(minutes=LOKI_BATCH_SIZE)).astimezone(timezone.utc)

    query = '{namespace="sock-shop", app="' + APP_NAME + '"}'

    params = {
        "query": query,
        "start": int(start_time.timestamp() * 1e9),
        "end": int(end_time.timestamp() * 1e9),
        "limit": 10000
    }

    headers = {
        "Content-Type": "application/json"
    }

    print(f"Fetching logs from {start_time} to {end_time} for app: {APP_NAME}...") 
    print(f"Query: {query}")

    response = requests.get(LOKI_URL + "/loki/api/v1/query_range", params=params,
                            headers=headers, auth=(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY))

    if response.status_code != 200:
        print("Error fetching logs from Loki API. Status code: ", response.status_code)
        print(response.content)
        exit(-1)

    raw_logs = response.json().get("data", {}).get("result", [])

    if raw_logs and any(log["values"] for log in raw_logs):
        base_folder_name = f"{APP_NAME}_logs"
        os.makedirs(base_folder_name, exist_ok=True)

        file_name = os.path.join(base_folder_name, f"{APP_NAME}_{timestamp}.txt")
        with open(file_name, "w") as f:
            for log in raw_logs:
                log_entries = log["values"]
                app_name = log["stream"].get("app")
                if app_name == APP_NAME:
                    for entry in log_entries:
                        entry_timestamp = entry[0]
                        message = entry[1]

                        try:
                            parsed_log = json.loads(message)
                        except json.JSONDecodeError:
                            parsed_log = message 

                        f.write(f"{entry_timestamp} 'app': '{app_name}' {parsed_log}\n")
        return file_name
    else:
        print(f"No logs found for timestamp {timestamp}. Skipping file creation.")
        return None


start_time = datetime(2024, 9, 15, 12, 0, 0)
end_time = datetime(2024, 9, 15, 12, 30, 0)

log_files = get_loki_logs(start_time)

print(f"Fetched log files: {log_files}")
