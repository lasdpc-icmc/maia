import prometheus_client
import boto3
import json
import os

def get_file_s3(file_name, prefix):
    s3 = boto3.client('s3')
    bucket_name = os.environ["S3_BUCKET_NAME"]
    response = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)
    last_object = max(response['Contents'], key=lambda x: x['LastModified'])
    last_object_key = last_object['Key']
    s3.download_file(bucket_name, last_object_key, file_name)


def get_json_s3(prefix):
    get_file_s3("in", prefix)

    f = open("in", "r")
    jsonin = json.load(f)
    f.close()
    
    return jsonin

registry = prometheus_client.CollectorRegistry()

precision = prometheus_client.Gauge(
    "deep_log_precision", "the general precision for the predictions",
    ["log", "type"], registry=registry)

accuracy = prometheus_client.Gauge(
    "deep_log_accuracy", "general accuracy for deep_log", registry=registry)

buckets = [0.05] + [0.1*i for i in range(1, 10)] + [float("inf")]

confidence = prometheus_client.Histogram(
    "deep_log_confidence", "confidence for each prediction",
    ["app", "log_prediced", "log"], buckets=buckets, registry=registry)

anomalies = prometheus_client.Gauge(
    "deep_log_anomalies", "number of anomalies for that batch", ["app", "log"],
    registry=registry)

# read the deep_log outputs from S3 as a json
jsonin = get_json_s3("deep_log/")

# find the relation between log lines and the apps that generated them
apps_list = jsonin["app"]

# parse the json and populate all metrics
s = "individual_pred"
for i, log in enumerate(jsonin[s]):
    if log == "accuracy":
        accuracy.set(jsonin[s][log])
        continue

    for precision_type in jsonin[s][log]:
        precision.labels(log, precision_type).set(
            jsonin[s][log][precision_type])

for i, prediction in enumerate(jsonin["predictions"]):
    confidence_point = jsonin["confidence"][i]
    anomaly = jsonin["anomalies"][i]

    for j, log_type in enumerate(prediction):
        confidence.labels(apps_list[i].split('}')[0], prediction[0],
                             log_type).observe(confidence_point[j])

    anomalies.labels(apps_list[i].split('}')[0],
                        prediction[0]).inc(1 if anomaly else 0)


# finally, use pushgateway to expose the metrics we just collected
def push_metrics_prometheus () :
    prometheus_client.push_to_gateway(
    os.environ["PUSHGATEWAY_URL"], "deep_log", registry)
    print("Successfully pushed metrics to Prometheus")