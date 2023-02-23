import requests
import json
import time
import os

LOKI_URL     = os.environ['LOKI_URL']
APP_NAME     = os.environ['APP_NAME']
TIME_RANGE     = int(os.environ['TIME_RANGE'])

end_time = int(time.time())  # current time in seconds
start_time = end_time - TIME_RANGE  # 60 minutes ago in seconds

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

    # Parse and print each log entry
    for log in raw_logs:
        stream = log["stream"]
        log_entries = log["values"]
        for entry in log_entries:
            timestamp = entry[0]
            message = entry[1]
            parsed_log = json.loads(message)
            print(stream, timestamp, parsed_log)
else:
    # Print the error message and content if the request failed
    print("Error fetching logs from Loki API. Status code: ", response.status_code)
    print(response.content)