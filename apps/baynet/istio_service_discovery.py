import requests
import json
import csv
import os
from datetime import datetime, timedelta

TEMPO_BASE_URL = os.environ["TEMPO_BASE_URL"]
PROMETHEUS_URL = os.environ["PROMETHEUS_URL"]
METRIC = os.environ["METRIC"]
SAMPLE = os.environ["SAMPLE"]
CSV_FILE = os.environ["CSV_FILE"]

END_TIME = datetime.now()
START_TIME = END_TIME - timedelta(hours=1)

def fetch_prometheus_data(url, query, start, end, step):
    params = {
        'query': query,
        'start': start.timestamp(),
        'end': end.timestamp(),
        'step': step
    }
    try:
        response = requests.get(url, params=params)
        print(f"Request URL: {response.url}")
        print(f"Response Status Code: {response.status_code}")
        print(f"Response Content: {response.text[:2000]}")  # Print first 2000 characters
        response.raise_for_status()
        data = response.json()
        print("Raw data from Prometheus:", json.dumps(data, indent=2))
        return data.get('data', {}).get('result', [])
    except requests.exceptions.RequestException as e:
        print(f"Error fetching data from Prometheus: {e}")
        return []
    except ValueError as e:
        print(f"Error decoding JSON: {e}")
        return []

def extract_service_relations(metric_data):
    relations = []

    for entry in metric_data:
        source = entry['metric'].get('source_canonical_service', 'unknown_source')
        destination = entry['metric'].get('destination_canonical_service', 'unknown_destination')

        if source != 'unknown_source' and destination != 'unknown_destination':
            relations.append((source, destination))
    
    return relations

def remove_duplicates(relations):
    return list(set(relations))

def export_to_csv(relations, filename):
    try:
        with open(filename, mode='w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(['Source', 'Destination'])
            for source, destination in relations:
                writer.writerow([source, destination])
        print(f"Relations exported to {filename}")
    except IOError as e:
        print(f"Error writing to CSV file: {e}")

def main():
    metric_data = fetch_prometheus_data(PROMETHEUS_URL, METRIC, START_TIME, END_TIME, SAMPLE)
    if not metric_data:
        print("No data returned from Prometheus.")
        return
    
    relations = extract_service_relations(metric_data)
    unique_relations = remove_duplicates(relations)
    export_to_csv(unique_relations, f"{CSV_FILE}/service_relations.csv")

if __name__ == '__main__':
    main()
