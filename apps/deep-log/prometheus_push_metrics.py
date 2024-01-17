import prometheus_client
import json
import os

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

    # read the deep_log outputs from S3 as a json
    jsonin = f"{file_name}_predict.json"

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

    prometheus_client.push_to_gateway(
        os.environ["PUSHGATEWAY_URL"], "deep_log", registry)
    print("Successfully pushed metrics to Prometheus")