import pandas as pd
import requests
import logging
import asyncio


async def getMetrics(metrics_file, test_start, dry_run, options):
    # add type of metric (counter or gauge) to table
    metrics = pd.read_csv(metrics_file)

    tasks = []
    for _, (name, kind, source) in metrics.iterrows():
        if source not in ["node_exporter", "cadvisor", "apm", "kube_state"]:
            raise ValueError(f"invalid metric source {source}")

        tasks.append(getMetric(source, kind, name, test_start, dry_run,
                               options))

    done, _ = await asyncio.wait(tasks)

    values = {}
    for i in done:
        name, value = i.result()
        values[name] = value

    return values


async def getMetric(source, kind, metric_name, test_start, dry_run, options):
    data = None
    if dry_run:
        data = getMockData(source)
    else:
        query = ""
        if kind == "counter":
            query += "irate("

        query += f'{metric_name}'

        if source != "node_exporter":
            query += f'{{namespace="{options["test_namespace"]}"}}'

        if kind == "counter":
            query += "[5m])"
        data = await getPrometheusData(source, query, test_start,
                                       options["test_seconds"])

    return metric_name, data


def getMockData(source):
    if source == "node_exporter":
        return {"ec2-0": [5, 4, 3, 2], "ec2-1": [1, 2, 3, 4]}
    else:
        return {"db": [1, 2, 3, 4], "rabbitmq": [3, 2, 5, 1]}


async def getPrometheusData(source, query, test_start, test_duration):
    logger = logging.getLogger("metric_gather")

    logger.info(f"starting query {query}")
    res = await asyncio.to_thread(requests.get,
                                  "http://localhost:9090/api/v1/query_range",
                                  params={
                                      "query": query,
                                      "start": test_start,
                                      "end": test_start + test_duration,
                                      "step": 30},
                                  )
    logger.info(f"got query {query}")

    if res.status_code != 200:
        raise ValueError(
            f"prometheus returned an error: {res.status_code}: " +
            f"{res.json()}")

    return formatData(source, res.json()["data"]["result"])


def formatData(source, values):
    data = {}
    for entry in values:
        ts_value = {}
        for value in entry["values"]:
            if ts_value.get(value[0]) is None:
                ts_value[value[0]] = 0
            ts_value[value[0]] += float(value[1])

        instance_type = "instance" if source == "node_exporter" else "pod"
        data[entry["metric"][instance_type]] = [
            v for _, v in sorted(ts_value.items())]

    return data
