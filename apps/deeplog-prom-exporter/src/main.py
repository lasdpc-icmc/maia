import prometheus_client
import os

# get the metrics we need to populate
import deep_metrics as dm
# and helper functions
import aws_tools

# read the deep_log outputs from S3 as a json
jsonin = aws_tools.get_json_s3("deep_log/")

# find the relation between log lines and the apps that generated them
apps_list = jsonin["app"]

# parse the json and populate all metrics
s = "individual_pred"
for i, log in enumerate(jsonin[s]):
    if log == "accuracy":
        dm.accuracy.set(jsonin[s][log])
        continue

    for precision_type in jsonin[s][log]:
        dm.precision.labels(log, precision_type).set(
            jsonin[s][log][precision_type])

for i, prediction in enumerate(jsonin["predictions"]):
    confidence_point = jsonin["confidence"][i]
    anomaly = jsonin["anomalies"][i]

    for j, log_type in enumerate(prediction):
        dm.confidence.labels(apps_list[i].split('}')[0], prediction[0],
                             log_type).observe(confidence_point[j])

    if anomaly:
        dm.anomalies.labels(apps_list[i].split('}')[0], prediction[0]).inc()

# finally, use pushgateway to expose the metrics we just collected
prometheus_client.push_to_gateway(
    os.environ["PUSHGATEWAY_URL"], "deep_log", dm.registry)
