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

  storage:
    bucketNames:
      chunks: lasdpc-loki-logs
    type: 's3'
    s3:
      endpoint: s3.us-east-1.amazonaws.com
      region: us-east-1
      s3ForcePathStyle: true
      insecure: false

promtail:
  enabled: true
  config:
    logLevel: info
    serverPort: 3101
    clients:
      - url: http://{{ .Release.Name }}:3100/loki/api/v1/push
