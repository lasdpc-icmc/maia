FROM python:3.10-alpine

COPY ./requirements.txt /srv/
COPY ./src/ /srv/
WORKDIR /srv/

RUN pip install -r /srv/requirements.txt

ENTRYPOINT python /srv/main.py
