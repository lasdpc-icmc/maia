loki:
  auth_enabled: false
  commonConfig:
    path_prefix: /var/loki
    replication_factor: 1
  compactor:
    apply_retention_interval: 1h
    compaction_interval: 5m
    retention_delete_worker_count: 500
    retention_enabled: true
    shared_store: s3
    working_directory: /data/compactor
  limits_config:
    retention_period: 365d
    max_entries_limit_per_query: 5000000
  config:
    schema_config:
      configs:
      - from: 2020-05-15
        store: boltdb-shipper
        object_store: s3
        schema: v11
        index:
          period: 24h
          prefix: loki_index_

    storage_config:
      aws:
        region: us-east-1
        bucketnames: lasdpc-loki-logs
        s3forcepathstyle: false
      boltdb_shipper:
        shared_store: s3
        cache_ttl: 24h

  serviceAccount:
    create: true
    name: loki-service
    annotations:
       eks.amazonaws.com/role-arn: "${role_arn}"
  write:
     replicas: 2
  read:
    replicas: 1

promtail:
  enabled: true
  config:
    logLevel: info
    serverPort: 3101
    clients:
      - url: http://loki.monitoring:3100/loki/api/v1/push
    snippets:
      pipelineStages:
        - cri: {}
        - multiline:
            firstline: '^\S'
            max_lines: 2048
