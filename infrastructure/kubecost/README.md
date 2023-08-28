 ## Deploy Kubecost using Helm
 
 ```bash
helm upgrade --install kubecost --namespace kubecost -f values.yaml --create-namespace \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --set kubecostToken="aGVsbUBrdWJlY29zdC5jb20=xm343yadf98"
```
