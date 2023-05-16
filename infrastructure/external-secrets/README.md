 ## Deploy External-Secrets using Helm
 
 ```bash
 helm repo add external-secrets https://charts.external-secrets.io
 helm repo update
 helm upgrade --install external-secrets --version 0.5.9 external-secrets/external-secrets -f values.yaml -n external-secrets --create-namespace
 ```
 