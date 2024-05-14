test_pod:
  enabled: true
  image: bats/bats:1.8.2
  pullPolicy: IfNotPresent

loki:
  enabled: true
  auth_enabled: false
  isDefault: true
  url: http://{{(include "loki.serviceName" .)}}:{{ .Values.loki.service.port }}
  readinessProbe:
    httpGet:
      path: /ready
      port: http-metrics
    initialDelaySeconds: 90
  livenessProbe:
    httpGet:
      path: /ready
      port: http-metrics
    initialDelaySeconds: 90
  limits_config:
    retention_period: 365d
    max_entries_limit_per_query: 5000000
  datasource:
    jsonData: "{}"
    uid: ""

minio:
    enabled: true

promtail:
  enabled: true
  config:
    logLevel: info
    serverPort: 3101
    clients:
      - url: http://{{ .Release.Name }}:3100/loki/api/v1/push