import pandas as pd
import requests
import logging


def getMetrics(metrics_file, test_start, dry_run, options):
    logger = logging.getLogger("metric_gather")

    # add type of metric (counter or gauge) to table
    metrics = pd.read_csv(metrics_file)

    values = {}
    for _, (name, kind, mtype) in metrics.iterrows():  
        if kind not in ["node-exporter", "cadvisor"]:
            raise ValueError(f"invalid metric kind {kind}")
        logger.info(f"getting metric {name}")

        values[name] = getMetric(kind, mtype, name, test_start, dry_run, 
                                 options)

    return values

def getMetric(kind, mtype, metric_name, test_start, dry_run, options):
    data = None
    if dry_run:
        data = getMockData(kind)
    else:
        query = ""
        if mtype == "counter":
            query += "rate("

        query += f'{metric_name}'

        if kind == "cadvisor":
            query += f'{{namespace="{options["test_namespace"]}"}}'

        if mtype == "counter":
            query += ")"
        data = getPrometheusData(kind, query, test_start, 
                                 options["test_seconds"])

    return data
    
def getMockData(kind):
    if kind == "node-exporter":
        return {"ec2-0": [5, 4, 3, 2], "ec2-1": [1, 2, 3, 4]}
    else:
        return {"db": [1, 2, 3, 4], "rabbitmq": [3, 2, 5, 1]}

def getPrometheusData(kind, query, test_start, test_duration):
    res = requests.get(
            "http://localhost:9090/api/v1/query_range", 
            params={
                "query":query, 
                "start":test_start, 
                "end":test_start + test_duration, 
                "step":30})

    if res.status_code != 200:
        raise ValueError(
                f"prometheus returned an error: {res.status_code}: " +
                f"{res.json()}")

    return formatData(kind, res.json()["data"]["result"])

def formatData(kind, values):
    data = {}
    for entry in values:
        ts_value = {}
        for value in entry["values"]:
            if ts_value.get(value[0]) is None:
                ts_value[value[0]] = 0
            ts_value[value[0]] += float(value[1])

        instance_type = "pod" if kind == "cadvisor" else "instance"
        data[entry["metric"][instance_type]] = [
                v for _, v in sorted(ts_value.items())]

    return data
