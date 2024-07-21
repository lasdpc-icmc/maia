import requests
from datetime import datetime, timedelta, timezone
import json
import os

BASE_URL = int(os.environ["BASE_URL"])
TRACE_TIME_RANGE_MINUTES = int(os.environ["TRACE_TIME_RANGE_MINUTES"])
SAVE_DIRECTORY = int(os.environ["SAVE_DIRECTORY"])
SERVICE_NAME= int(os.environ["SERVICE_NAME"])

def get_trace_ids_from_last_n_minutes_for_service(service_name, minutes):
    end_time = datetime.now(timezone.utc)
    start_time = end_time - timedelta(minutes=minutes)

    start_time_unix = int(start_time.timestamp())
    end_time_unix = int(end_time.timestamp())

    print(f"Time range: {start_time_unix} to {end_time_unix}")

    params = {
        "tags": f"service.name={service_name}",
        "start": start_time_unix,
        "end": end_time_unix,
        "limit": 100
    }

    response = requests.get(f"{BASE_URL}/api/search", params=params)

    print(f"Request URL: {response.url}")

    if response.status_code == 200:
        data = response.json()
        trace_ids = [trace["traceID"] for trace in data.get("traces", [])]
        return trace_ids
    else:
        print(f"Failed to retrieve data: {response.status_code} - {response.text}")
        return []

def get_trace_details(trace_id):
    response = requests.get(f"{BASE_URL}/api/traces/{trace_id}")

    print(f"Request URL: {response.url}")

    if response.status_code == 200:
        trace_data = response.json()
        return trace_data
    else:
        print(f"Failed to retrieve trace details: {response.status_code} - {response.text}")
        return None

def extract_span_attributes(span):
    attributes = {}
    for attr in span.get("attributes", []):
        key = attr.get("key")
        value = attr.get("value", {}).get("stringValue")

        if key in ["http.status_code", "http.method"]:
            attributes[key] = value

    return attributes

def generate_span_json(trace_data):
    span_info_list = []

    if trace_data:
        for span_set in trace_data.get("spanSets", []):
            for span in span_set.get("spans", []):
                span_info = {
                    "spanID": span.get("spanID", "Unknown Span ID"),
                    "startTime": span.get("startTimeUnixNano", "Unknown Start Time"),
                    "durationNanos": span.get("durationNanos", "Unknown Duration"),
                    "attributes": extract_span_attributes(span)
                }
                span_info_list.append(span_info)

    return span_info_list

def save_trace_to_file(trace_id, trace_data):
    os.makedirs(SAVE_DIRECTORY, exist_ok=True)

    file_path = os.path.join(SAVE_DIRECTORY, f"{trace_id}.json")

    with open(file_path, 'w') as file:
        json.dump(trace_data, file, indent=2)
    print(f"Saved trace data to {file_path}")

if __name__ == "__main__":
    service_name = SERVICE_NAME
    trace_ids = get_trace_ids_from_last_n_minutes_for_service(service_name, TRACE_TIME_RANGE_MINUTES)
    print(f"Trace IDs from the last {TRACE_TIME_RANGE_MINUTES} minutes for service '{service_name}':")
    
    for trace_id in trace_ids:
        print(f"Fetching details for Trace ID: {trace_id}")
        trace_data = get_trace_details(trace_id)
        if trace_data:
            save_trace_to_file(trace_id, trace_data)
