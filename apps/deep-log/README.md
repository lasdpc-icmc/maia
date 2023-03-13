# Deep Log application

## Dependencies

* python > 3.9
* docker


To build the docker image:

```bash
docker build -t deep_log:v1 .
```

## Mechanisms

We have a simple tool to deal with all applications over different environments, on the flow section we'll describe how to use all of them. 
Basically, we have dev and prod environments, with the **tool** script we just call the function with application and environment.

- Deploy all resources and developers and production environments
- Use Docker containers to slipt applications accross EKS

## Flow

To install all dependencies and create a python virtual environment:

```bash
virtualenv env
source env/bin/activate
pip install -r requirements.txt
```

To run the Drain Parsen application locally, using a Docker container:

```bash
./tool dev-loki
```

```bash
./tool dev-deep-log
```

Both will run the same code, but in the dev environment, we have some parameters enabled to improve the code delivery and test locally.