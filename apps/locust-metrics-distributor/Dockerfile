FROM python:3.8.16-alpine3.17

WORKDIR /srv

COPY . /srv/

RUN pip install -r requirements.txt

ENTRYPOINT ["/usr/local/bin/python3", "/srv/main.py"]

