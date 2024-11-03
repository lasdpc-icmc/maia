import requests
from datetime import datetime, timedelta, timezone
import os
import csv

PROMETHEUS_URL = os.environ.get("PROMETHEUS_URL", "http://localhost:9090/api/v1/query_range")
TIME_WINDOW = int(os.environ.get("TIME_WINDOW", "30"))
SERVICE_NAME = os.environ.get("SERVICE_NAME", "payment")
SERVICE_SUFFIX = ".sock-shop.svc.cluster.local"
SAVE_DIRECTORY = os.environ.get("SAVE_DIRECTORY", "traces")
BASE_URL = os.environ.get("BASE_URL", "http://localhost:3100")


def query_prometheus(service_name):
    full_service_name = f"{service_name}{SERVICE_SUFFIX}"
    query = f"""
    sum(irate(istio_requests_total{{reporter=~"destination",destination_service=~"{full_service_name}",response_code!~"5.*"}}[5m])) /
    (sum(irate(istio_requests_total{{reporter=~"destination",destination_service=~"{full_service_name}"}}[5m])) or on () vector(1))
    """

    end_time = datetime.now(timezone.utc).timestamp()
    start_time = end_time - TIME_WINDOW * 60  # Adjust the time range

    params = {
        "query": query.strip(),
        "start": start_time,
        "end": end_time,
        "step": "60s"
    }

    try:
        response = requests.get(PROMETHEUS_URL, params=params)
        print(f"Prometheus Query URL: {response.url}")
        response.raise_for_status()

        data = response.json()
        if data["status"] == "success":
            result = data["data"]["result"]
            if result:
                return result
            else:
                print(f"No data returned for service {full_service_name}")
                return None
        else:
            print(f"Query failed: {data['error']}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return None
    except ValueError as e:
        print(f"Failed to decode JSON response: {e}")
        return None

def p99_request_1h_average(service_name):
    full_service_name = f"{service_name}{SERVICE_SUFFIX}"
    query = f"""
    histogram_quantile(0.99, sum(irate(istio_request_duration_milliseconds_bucket{{reporter="destination",destination_service=~"{full_service_name}"}}[1m])) by (le))
    """

    end_time = datetime.now(timezone.utc).timestamp()
    start_time = end_time - 3600  # Last 1 hour

    params = {
        "query": query.strip(),
        "start": start_time,
        "end": end_time,
        "step": "60s"
    }

    try:
        response = requests.get(PROMETHEUS_URL, params=params)
        print(f"Prometheus Query URL for P99: {response.url}")
        response.raise_for_status()

        data = response.json()
        if data["status"] == "success":
            result = data["data"]["result"]
            if result and result[0]["values"]:
                return float(result[0]["values"][0][1])  # Return the p99 value as a float
            else:
                print(f"No data returned for P99 for service {full_service_name}")
                return None
        else:
            print(f"P99 Query failed: {data['error']}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return None
    except ValueError as e:
        print(f"Failed to decode JSON response: {e}")
        return None

def get_trace_ids_from_last_n_minutes_for_service(service_name, minutes):
    end_time = datetime.now(timezone.utc)
    start_time = end_time - timedelta(minutes=minutes)

    start_time_unix = int(start_time.timestamp())
    end_time_unix = int(end_time.timestamp())

    params = {
        "tags": f"service.name={service_name}",
        "start": start_time_unix,
        "end": end_time_unix,
        "limit": 100
    }

    try:
        response = requests.get(f"{BASE_URL}/api/search", params=params)
        if response.status_code == 200:
            data = response.json()
            trace_ids = [trace["traceID"] for trace in data.get("traces", [])]
            return trace_ids
        else:
            print(f"Failed to retrieve data: {response.status_code} - {response.text}")
            return []
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return []

def get_trace_details(trace_id):
    response = requests.get(f"{BASE_URL}/api/traces/{trace_id}")

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

def save_traces_to_csv(trace_data_list, metric_values, p99_value):
    os.makedirs(SAVE_DIRECTORY, exist_ok=True)

    file_path = os.path.join(SAVE_DIRECTORY, "traces.csv")

    all_keys = set()
    for span_info_list in trace_data_list:
        for span in span_info_list:
            all_keys.update(span["attributes"].keys())

    metric_value = "N/A"
    if metric_values and metric_values[0]["values"]:
        metric_value = metric_values[0]["values"][0][1]

    with open(file_path, 'w', newline='') as file:
        writer = csv.writer(file)
        header = ["spanID", "startTime", "durationNanos", "2xx_rate", "p99"] + list(all_keys)
        writer.writerow(header)

        for span_info_list in trace_data_list:
            for span in span_info_list:
                row = [
                    span.get("spanID"),
                    span.get("startTime"),
                    span.get("durationNanos"),
                    metric_value,
                    p99_value if p99_value is not None else "N/A"  # Handle None case
                ]
                for key in all_keys:
                    row.append(span["attributes"].get(key, "N/A"))  # Handle missing attributes
                writer.writerow(row)
    print(f"Saved trace and metric data on {file_path}")


if __name__ == "__main__":
    service_name = SERVICE_NAME
    metric_values = query_prometheus(service_name)
    
    # Get the P99 value for the service
    p99_value = p99_request_1h_average(service_name)

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
        save_traces_to_csv(all_span_info_list, metric_values, p99_value)  # Pass the p99_value here
