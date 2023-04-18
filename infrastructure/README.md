# Metrics Application on AWS EKS

## How to setup awscli

### Download and install
To setup the AWS command line interface, start by downloading the awscli binary (if you are not on linux x86\_64 the command will be different):
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
cd aws/
```

After that, install it either in the whole system with `sudo ./install` or only for the current user with `./install -i ~/.local/share/aws-cli -b ~/.local/bin`

### Creating a user access key
To create a access key, go to the [aws site](https://aws.amazon.com/) and log in. In the search bar, search for "iam" (AWS identity and access management)

![stats](setup/IAM.png)


then, go to "Users" in the left bar, click on your user, and, under "security credentials" / "access keys", click on "create access key"

![stats](setup/accesskey.png)

Save both your key ID and the secret, this is the only time you will be able to see the secret.

### Log in using the aws binary
Log in using your access key and secret via `aws configure`, and select the default region as `us-east-1`, leaving other configurations blank.

## How to access the EKS Cluster
Use `aws eks update-kubeconfig --name prod-application-metrics`, where prod-application-metrics is the name of our cluster, to generate a .kube/config. Then you can use `kubectl` as normal, for example:

```bash
kubectl get nodes

NAME                             STATUS   ROLES    AGE    VERSION
ip-172-20-105-85.ec2.internal    Ready    <none>   161m   v1.22.15-eks-9c63c4
ip-172-20-112-145.ec2.internal   Ready    <none>   162m   v1.22.15-eks-9c63c4
```

## Access Grafana and Loki

To access the monitoring stack services you need to login with Github SS0:

https://grafana-lasdpc.icmc.usp.br/

![stats](setup/grafana.png)

## Deploy applications using CircleCI


## Cluster Information

**Kubernetes v1.23 + Weave Net addon**

EKS = v1.23<p>
Istio = 1.17<p>

**Monitoring Stack**

kube-prometheus =

# Install Istio

Install the istioctl binary:

```shell
curl -sL https://istio.io/downloadIstioctl | sh -
```
```shell
$ export PATH=$HOME/.istioctl/bin:$PATH
```

Install the istio service mesh with custom parameters provided by istio.yaml file.

```shell
istioctl manifest apply -f istio/istio.yaml
```

## Install Istio Addons

To quickly deploy all addons:

```shell
kubectl apply -f istio/addons
```


# Kiali

https://istio.io/latest/docs/ops/diagnostic-tools/istioctl/

Kiali:

```bash
kubectl port-forward service/kiali 20001:20001 -n istio-system
```

Open your browser in localhost:20001

![stats](setup/kiali.png)

## References

[1] https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html <p>
[2] https://www.weave.works/docs/net/latest/kubernetes/kube-addon/#install <p>
[3] https://istio.io/latest/docs/setup/getting-started/ <p>
