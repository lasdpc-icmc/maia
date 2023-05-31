import prometheus_client

registry = prometheus_client.CollectorRegistry()

precision = prometheus_client.Gauge(
    "deep_log_precision", "the general precision for the predictions", ["log", "type"], registry=registry)

accuracy = prometheus_client.Gauge(
    "deep_log_accuracy", "general accuracy for deep_log", registry=registry)

buckets = [0.05] + [0.1*i for i in range(1, 10)] + [float("inf")]
confidence = prometheus_client.Histogram(
    "deep_log_confidence", "confidence for each prediction", ["log_prediced", "log"], buckets=buckets, registry=registry)

anomalies = prometheus_client.Gauge(
    "deep_log_anomalies", "number of anomalies for that batch", ["log"], registry=registry)
