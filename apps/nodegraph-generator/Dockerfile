FROM python:3.10-alpine

WORKDIR /srv/

COPY ./requirements.txt /srv/
RUN pip install -r /srv/requirements.txt

COPY ./fields.json /srv/
COPY ./src/ /srv/

ENTRYPOINT python /srv/main.py
