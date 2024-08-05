import requests
from datetime import datetime, timedelta, timezone
import json
import os
import csv

BASE_URL = os.environ["BASE_URL"]
TIME_WINDOW = int(os.environ["TIME_WINDOW"])
SAVE_DIRECTORY = os.environ["SAVE_DIRECTORY"]
SERVICE_NAME = os.environ["SERVICE_NAME"]

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
        attributes[key] = value

    return attributes

def generate_span_list(trace_data):
    span_info_list = []

    if trace_data:
        for batch in trace_data.get("batches", []):
            for scopeSpan in batch.get("scopeSpans", []):
                for span in scopeSpan.get("spans", []):
                    span_info = {
                        "spanID": span.get("spanId", "Unknown Span ID"),
                        "startTime": span.get("startTimeUnixNano", "Unknown Start Time"),
                        "endTime": span.get("endTimeUnixNano", "Unknown End Time"),
                        "attributes": extract_span_attributes(span)
                    }
                    span_info["durationNanos"] = int(span_info["endTime"]) - int(span_info["startTime"])
                    span_info_list.append(span_info)

    return span_info_list

def save_traces_to_csv(trace_data_list):
    os.makedirs(SAVE_DIRECTORY, exist_ok=True)

    file_path = os.path.join(SAVE_DIRECTORY, "traces.csv")

    # Get all KV from traces
    all_keys = set()
    for span_info_list in trace_data_list:
        for span in span_info_list:
            all_keys.update(span["attributes"].keys())

    with open(file_path, 'w', newline='') as file:
        writer = csv.writer(file)
        header = ["spanID", "startTime", "durationNanos"] + list(all_keys)
        writer.writerow(header)

        for span_info_list in trace_data_list:
            for span in span_info_list:
                row = [
                    span.get("spanID"),
                    span.get("startTime"),
                    span.get("durationNanos")
                ]
                for key in all_keys:
                    row.append(span["attributes"].get(key))
                writer.writerow(row)
    print(f"Saved trace on {file_path}")

if __name__ == "__main__":
    service_name = SERVICE_NAME
    trace_ids = get_trace_ids_from_last_n_minutes_for_service(service_name, TIME_WINDOW)
    print(f"Trace IDs from the last {TIME_WINDOW} minutes for service '{service_name}':")
    
    all_span_info_list = []
    for trace_id in trace_ids:
        print(f"Fetching details for Trace ID: {trace_id}")
        trace_data = get_trace_details(trace_id)
        if trace_data:
            span_info_list = generate_span_list(trace_data)
            all_span_info_list.append(span_info_list)
    
    if all_span_info_list:
        save_traces_to_csv(all_span_info_list)
