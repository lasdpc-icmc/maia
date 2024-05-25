serviceAccount:
  create: true
  name: loki
  annotations:
    eks.amazonaws.com/role-arn: "${role_arn}"

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

  storage_config:
    tsdb_shipper:
      active_index_directory: /loki/index
      cache_location: /loki/index_cache
      cache_ttl: 24h
    aws:
      s3: s3://us-east-1
      bucketnames: lasdpc-loki-logs
  schemaConfig:
    configs:
      - from: 2020-07-01
        store: tsdb
        object_store: aws
        schema: v13
        index:
          prefix: index_
          period: 24h
  
promtail:
  enabled: true
  config:
    logLevel: info
    serverPort: 3101
    clients:
      - url: http://{{ .Release.Name }}:3100/loki/api/v1/push
