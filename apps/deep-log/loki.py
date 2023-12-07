import requests
import json
import time
import os

LOKI_URL = os.environ["LOKI_URL"]
APP_NAME = os.environ["APP_NAME"]
TIME_RANGE = int(os.environ["TIME_RANGE"])
AWS_ACCESS_KEY_ID = os.environ["AWS_ACCESS_KEY_ID"]
AWS_SECRET_ACCESS_KEY = os.environ["AWS_SECRET_ACCESS_KEY"]

def get_loki_logs(batch_id):

    # each batch has 60 seconds of logs
    now = int(time.time())
    end_time = now - TIME_RANGE + (batch_id + 1) * 60
    start_time = now - TIME_RANGE + batch_id * 60

    query = '{namespace ="' + APP_NAME + '"}'

    params = {
        "query": query,
        "start": start_time,
        "end": end_time,
        "limit": 5000
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
    file_name = os.path.join(base_folder_name, f"{APP_NAME}_{batch_id}.txt")
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
