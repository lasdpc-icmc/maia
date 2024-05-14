# Configurando backups no Velero

## Dependências

* velero 1.13.0 [1]
* kubectl 1.27+


Para criar um backup com TTL padrão de 30 dias:

```bash
velero backup create test --include-namespaces test 
```

Para agendar um backup incluindo todos os namespaces e todos os objetos:

```bash
velero schedule create meu-backup-full --schedule="0 0 * * *" --include-resources '*' --include-namespaces '*' --ttl 24h
```

Para agendar um backup incluindo apenas o namespace da minha aplicação e todos os seus objetos:

```bash
velero schedule create meu-app-backup-full --schedule="0 0 * * *" --include-resources '*' --include-namespaces 'meu-namespace' --ttl 24h
```

Para listar os backups disponíveis:

```bash
velero backup get
```

Para importar um backup existente:

```bash
velero restore create --from-backup meu-app-backup-full --include-namespaces 'meu-namespace' --include-resources 'secrets'
```

# Referências

[1] - https://github.com/vmware-tanzu/velero/releases/tag/v1.13.0-rc.1