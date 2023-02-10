# Marea Turbo - Deep Log application

## Dependencies

* python > 3.9
* poetry > 0.12
* docker

## Mechanisms

We have a simple tool to deal with all applications over different environments, on the flow section we'll describe how to use all of them. 
Basically, we have dev and prod environments, with the **tool** script we just call the function with application and environment.

- Deploy all resources and developers and production environments
- Use Docker containers to slipt applications accross EKS

## Flow

To install all dependencies and create a python virtual environment:

```bash
poetry install
```

To run the Drain Parsen application locally, using a Docker container:

```bash
./tool dev-drain-parser
```

```bash
./tool prod-drain-parser
```

Both will run the same code, but in the dev environment, we have some parameters enabled to improve the code delivery and test locally.