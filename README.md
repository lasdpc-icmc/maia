# MAIA (Multi-Cloud Analytics with Integrated AI)


1. Conceptual and comparative application metrics analysis in native cloud microservices
2. Dynamic streaming log analysis using Deep Learning

***Overview***
-------------------

Cloud computing technologies offer significant advantages in scalability and performance, enabling rapid deployment of applications. The adoption of microservices-oriented architectures has introduced an ecosystem characterized by an increased number of applications, frameworks, abstraction layers, orchestrators, and hypervisors, all operating within distributed systems. This complexity results in the generation of vast quantities of logs from diverse sources, making the analysis of these events an inherently challenging task, particularly in the absence of automation. To address this issue, Machine Learning techniques leveraging Large Language Models (LLMs) offer a promising approach for dynamically identifying patterns within these events. In this study, we propose a novel anomaly detection framework utilizing a microservices architecture deployed on Kubernetes and Istio, enhanced by an LLM model. The model was trained on various error scenarios, with Chaos Mesh employed as an error injection tool to simulate faults of different natures, and Locust used as a load generator to create workload stress conditions. After an anomaly is detected by the LLM model, we employ a dynamic Bayesian network to provide probabilistic inferences about the incident, proving the relationships between components and assessing the degree of impact among them. Additionally, a ChatBot powered by the same LLM model allows users to interact with the AI, ask questions about the detected incident, and gain deeper insights. The experimental results demonstrated the model's effectiveness, reliably identifying all error events across various test scenarios. While it successfully avoided missing any anomalies, it did produce some false positives, which remain within acceptable limits.

## Repositories

This project is divided across a few GitHub repositories:

- [infrastructure](https://github.com/diegopedroso/metric-application-microservices/tree/main/infrastructure). Repo with infrastructure provisioning as a code on AWS, also all Terraform code and Kubernetes manifests to monitoring components.

- [circleci](https://github.com/diegopedroso/metric-application-microservices/tree/main/.circleci). Repo with the CI/CD codes of the platform that performs the deployments.

- [apps](https://github.com/diegopedroso/metric-application-microservices/tree/main/apps). Repo with all applications that run within the Kubernetes cluster, as well as k8s manifests, load tests, and all application-level configurations.


About
-------------------
Sarita Mazzini Bruschi - <sarita@icmc.usp.br> <p>
Júlio Cezar Estrella - <jcezar@icmc.usp.br> <p>
Diego Frazatto Pedroso - <diegopedroso@usp.br> <p>
