import boto3
import flask
import threading
import time
import datetime
from botocore.exceptions import ClientError

locust_metrics_file = "/tmp/locust.metrics"
file_lock = threading.Lock()

server = flask.Flask("locust-metrics-distributor")

@server.route("/metrics")
def send_metris():
    while file_lock.locked():
        time.sleep(0.1)
    return flask.send_file(locust_metrics_file)

def get_metrics_s3():
    client = boto3.client("s3")

    lasttime = datetime.datetime(2015, 1, 1)
    while True:
        try:
            response = client.get_object(
                Bucket="lasdpc-locust-results",
                Key="sock-shop/locust.metrics",
                IfModifiedSince=lasttime
            )
        except ClientError as e:
            if e.response["Error"]["Code"] != 304:
                print("Error", e.response["Error"]["Message"])
            time.sleep(15)
            continue

        file_lock.acquire()
        f = open(locust_metrics_file, "wb")
        f.write(response["Body"].read())
        f.close()
        file_lock.release()

        lasttime = datetime.datetime.utcnow()

        time.sleep(15)

if __name__ == "__main__":
    open(locust_metrics_file, "w").close()

    s3thread = threading.Thread(target=get_metrics_s3)
    s3thread.start()

    server.run("0.0.0.0", 8080)
