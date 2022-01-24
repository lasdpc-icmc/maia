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
Istio = 1.12.2

**Monitoring Stack**

kube-prometheus = release-0.10

**Istio**

Go to the Istio release page to download the installation file for your OS, or download and extract the latest release automatically (Linux or macOS):

```bash
curl -L https://istio.io/downloadIstio | sh -
```

Download the last version:

```bash
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.12.2 TARGET_ARCH=x86_64 sh -
```

Move to the Istio package directory. For example, if the package is istio-1.12.2:

```bash
export PATH=$PWD/bin:$PATH
```

For this installation, we use the demo configuration profile. It’s selected to have a good set of defaults for testing, but there are other profiles for production or performance testing.

```bash
istioctl install --set profile=demo -y
```
Add a namespace label to instruct Istio to automatically inject Envoy sidecar proxies when you deploy your application later:

```bash
kubectl --kubeconfig setup/config label namespace default istio-injection=enabled
```

Install istio observability tools:

```bash
kubectl --kubeconfig setup/config apply -f samples/addons
```

To access the istio observability stack you need to forward the traffic using kubectl port-forward. There is no public traffic in this setup.

Kiali:

```bash
kubectl --kubeconfig setup/config port-forward service/kiali 20001:20001 -n istio-system   
```

Open your browser in localhost:20001

![stats](setup/kiali.png)

## References

[1] https://www.weave.works/docs/net/latest/kubernetes/kube-addon/#install <p>
[2] https://istio.io/latest/docs/setup/getting-started/ <p>