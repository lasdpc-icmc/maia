# MAIA (Multi-Cloud Analytics with Integrated AI)


1. Conceptual and comparative application metrics analysis in native cloud microservices
2. Dynamic streaming log analysis using Deep Learning

***Overview***
-------------------

Cloud computing offers significant benefits in terms of scalability and performance. The cloud scalability gives developers the ability to fastly deploy large amounts of computing and storage resources. Given the volatility of cloud computing systems, monitoring and analyzing the behavior of these environments is a challenge, as the parameters and guidelines that guide these environments are constantly changing. The constant evolutions and integrations of complex system technologies exponentially increase the amount of records logs generated as we move towards cloud architectures oriented to microservices, making it even more difficult to manipulate, store and extract relevant information from these sources of data. Most existing monitoring solutions do not provide explicit data and most of the time it is up to the developer to identify patterns in dashboards, define and adjust alert rules, and search logs across multiple layers to find the root cause. The patterns that lead to these events change significantly, making it difficult to use predefined thresholds to detect anomalies. In this way, machine learning techniques can learn to capture these patterns for any system quickly and these relationships can be scaled far beyond the human capacity to keep up with the growing complexity of high performance systems, helping to reduce mitigation time and system repair time. This work proposes an incident detection system using unsupervised machine learning to automatically find the root cause of incidents. It is expected that this system will be able to perform probabilistic inferences using bayesian networks with a generic approach enough that the concepts discussed can be incorporated into various applications in order to offer tangible and automatic guidance for incident detection.

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
