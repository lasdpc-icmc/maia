FROM python:3.9.13

RUN apt update && apt install -y tree fzf entr

ADD . /root/workspace
WORKDIR /root/workspace

RUN pip install -r requirements.txt

RUN echo 'alias ee="ls -ahl"' > ~/.bashrc