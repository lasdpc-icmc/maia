import requests
import json
import time
import os
global file_name

LOKI_URL = os.environ['LOKI_URL']
APP_NAME = os.environ['APP_NAME']
TIME_RANGE = int(os.environ['TIME_RANGE'])
AWS_ACCESS_KEY_ID = os.environ['AWS_ACCESS_KEY_ID']
AWS_SECRET_ACCESS_KEY = os.environ['AWS_SECRET_ACCESS_KEY']
BATCH_SIZE = int(os.environ['BATCH_SIZE'])

def get_loki_logs(LOKI_URL, APP_NAME, TIME_RANGE, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY):
    end_time = int(time.time())
    start_time = end_time - TIME_RANGE
    query = '{namespace ="' + APP_NAME + '"}'

    params = {
        "query": query,
        "start": start_time,
        "end": end_time,
        "limit": BATCH_SIZE,
        "batch": BATCH_SIZE,
        "direction": "forward"
    }

    headers = {
        "Content-Type": "application/json"
    }

    total_files = 0
    lines_written = 0

    while True:
        response = requests.get(LOKI_URL + "/loki/api/v1/query_range", params=params,
                                headers=headers, auth=(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY))

        if response.status_code != 200:
            print("Error fetching logs from Loki API. Status code: ",
                  response.status_code)
            print(response.content)
            exit(-1)

        raw_logs = response.json()["data"]["result"]

        if not raw_logs:
            break

        base_folder_name = f"{APP_NAME}_logs"
        os.makedirs(base_folder_name, exist_ok=True)
        base_file_name = f"{base_folder_name}/{APP_NAME}_{int(time.time())}_{total_files + 1}.txt"
        f = open(base_file_name, "a")
        total_files += 1

        for log in raw_logs:
            stream = log["stream"]
            log_entries = log["values"]

            for entry in log_entries:
                timestamp = entry[0]
                message = entry[1]
                parsed_log = json.loads(message)

                f.write(f"{stream} {timestamp} {parsed_log}\n")
                lines_written += 1

                if lines_written >= BATCH_SIZE * total_files:
                    f.close()
                    break

        f.close()

    return total_files