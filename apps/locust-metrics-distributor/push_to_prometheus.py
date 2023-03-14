import main
import os
from prometheus-client import CollectorRegistry, Gauge, push_to_gateway

# Create a registry to hold the metrics
registry = CollectorRegistry()

# Open the file and read its contents

Bucket = os.environ['BUCKET_NAME']
Key = os.environ['KEY_NAME']
main.get_metrics_s3(Bucket,Key)

with open('metrics.txt', 'r') as f:
    lines = f.readlines()

# Parse the metrics and add them to the registry
for line in lines:
    # Split the line into the metric name, value, and any labels
    parts = line.strip().split(' ')
    metric_name = parts[0]
    metric_value = float(parts[1])
    labels = {}
    for label in parts[2:]:
        key, value = label.split('=')
        labels[key] = value

    # Create or retrieve the Gauge metric and set its value
    g = Gauge(metric_name, 'A gauge metric', labelnames=labels.keys(), registry=registry)
    g.labels(**labels).set(metric_value)

# Push the metrics to a Prometheus datasource
push_to_gateway('http://kube-prometheus-kube-prome-prometheus.monitoring:9091', job='locust-metrics', registry=registry)