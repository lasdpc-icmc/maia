FROM python:3.8.16-alpine3.17

WORKDIR /srv

COPY . /srv/

RUN pip install -r requirements.txt


ENV BUCKET_NAME "lasdpc-locust-results"
ENV KEY_NAME "sock-shop/locust.metrics"
ENV PUSHGATEWAY_URL "http://localhost:9091"

ENTRYPOINT ["/usr/local/bin/python3", "/srv/main.py"]

