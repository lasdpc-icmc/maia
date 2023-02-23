FROM python:3.9.7

RUN apt update && apt install -y tree fzf entr
RUN pip install poetry

ADD . /root/workspace
WORKDIR /root/workspace

RUN poetry install

RUN echo 'alias ee="ls -ahl"' > ~/.bashrc