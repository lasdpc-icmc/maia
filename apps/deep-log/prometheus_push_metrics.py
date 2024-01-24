import prometheus_client
import json
import os

APP_NAME = os.environ["APP_NAME"]

def push_metrics_prometheus(file_name):
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

    # read the deep_log outputs as a json
    file_name = file_name[:-4]
    json_file_path = f'{file_name}_predict.json'

    with open(json_file_path, 'r') as json_file:
        json_data = json.load(json_file)

    # find the relation between log lines and the apps that generated them
    apps_list = json_data["app"]

    # parse the json and populate all metrics
    s = "individual_pred"
    for i, log in enumerate(json_data[s]):
        if log == "accuracy":
            accuracy.set(json_data[s][log])
            continue

        for precision_type in json_data[s][log]:
            precision.labels(log, precision_type).set(
                json_data[s][log][precision_type])

    for i, prediction in enumerate(json_data["predictions"]):
        confidence_point = json_data["confidence"][i]
        anomaly = json_data["anomalies"][i]

        for j, log_type in enumerate(prediction):
            confidence.labels(apps_list[i].split('}')[0], prediction[0],
                                 log_type).observe(confidence_point[j])

        anomalies.labels(apps_list[i].split('}')[0],
                            prediction[0]).inc(1 if anomaly else 0)

    prometheus_client.push_to_gateway(
        os.environ["PUSHGATEWAY_URL"], "deep_log", registry)
    print("Successfully pushed metrics to Prometheus")