# Configuração de playbook Ansible para Deploy do Cluster K8S

### Deploy a Kubernetes cluster
É preciso configurar os hosts no arquivo de inventários, após essa configuração:

```sh
$ ansible-playbook -i inventory/hosts.ini cluster.yml
```

Para executar os addons de rede do cluster:
```sh
$ ansible-playbook -i inventory/hosts.ini addons.yml
```

### Reset cluster
Para deletar o cluster de forma permanente:
```sh
$ ansible-playbook -i inventory/hosts.ini reset-cluster.yml
```
