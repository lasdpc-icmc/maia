# How to access the Cluster

Copy the file setup/config and set env vars. All tokens are available in the master node (~/.kube/config)

Point the kubectl to the new environment:

```bash
kubectl --kubeconfig setup/config
```

Example:

```bash
kubectl --kubeconfig setup/config get nodes

NAME          STATUS   ROLES                  AGE   VERSION
master-node   Ready    control-plane,master   10d   v1.23.1
worker01      Ready    <none>                 10d   v1.23.1
worker02      Ready    <none>                 10d   v1.23.1    
```


## Access Granafa and Prometheus

To access the monitoring stack services you need to forward the traffic using kubectl port-forward. There is no public traffic in this setup.

Grafana:

```bash
kubectl --kubeconfig setup/config port-forward service/grafana 3000:3000 -n monitoring   
```
Prometheus:

```bash
kubectl --kubeconfig setup/config port-forward service/prometheus-k8s 9090:9090 -n monitoring   
```

Open your browser in localhost:3000

![stats](setup/grafana.png)

username: admin <p>
password: usp2022 <p>


## Cluster Information

**Kubernetes v1.23.1 + Weave Net addon**

kubeadm = v1.23.1<p>
kubectl = v1.23.1<p>
kubelet = v1.23.1<p>

**Monitoring Stack**

kube-prometheus = release-0.10


## References

https://www.weave.works/docs/net/latest/kubernetes/kube-addon/#install