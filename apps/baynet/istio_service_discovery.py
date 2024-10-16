import requests
import json
import csv
import os
from datetime import datetime, timedelta

TEMPO_BASE_URL = os.environ["TEMPO_BASE_URL"]
PROMETHEUS_URL = os.environ["PROMETHEUS_URL"]
CSV_FILE = os.environ["CSV_FILE"]

METRICS = os.environ["METRICS"].split(',')
SAMPLE = os.environ["SAMPLE"]

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
        print(f"Response Content: {response.text[:2000]}")
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

        if source == 'unknown':
            source = 'prometheus'
        if destination == 'unknown':
            destination = 'prometheus'

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
    all_relations = []

    for metric in METRICS:
        print(f"Fetching data for metric: {metric}")
        metric_data = fetch_prometheus_data(PROMETHEUS_URL, metric, START_TIME, END_TIME, SAMPLE)
        if metric_data:
            relations = extract_service_relations(metric_data)
            all_relations.extend(relations)
        else:
            print(f"No data returned for metric: {metric}")
    
    if all_relations:
        unique_relations = remove_duplicates(all_relations)
        export_to_csv(unique_relations, f"{CSV_FILE}/service_relations.csv")
    else:
        print("No data to export.")

if __name__ == '__main__':
    main()
