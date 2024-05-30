replicaCount: 1

# -- Specifies the amount of historic ReplicaSets k8s should keep (see https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy)
revisionHistoryLimit: 10

image:
  repository: ghcr.io/external-secrets/external-secrets
  pullPolicy: IfNotPresent
  # -- The image tag to use. The default is the chart appVersion.
  # There are different image flavours available, like distroless and ubi.
  # Please see GitHub release notes for image tags for these flavors.
  # By default the distroless image is used.
  tag: ""

# -- If set, install and upgrade CRDs through helm chart.
installCRDs: true

crds:
  # -- If true, create CRDs for Cluster External Secret.
  createClusterExternalSecret: true
  # -- If true, create CRDs for Cluster Secret Store.
  createClusterSecretStore: true
  # -- If true, create CRDs for Push Secret.
  createPushSecret: true
  annotations: {}
  conversion:
    enabled: true

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

# -- Additional labels added to all helm chart resources.
commonLabels: {}

# -- If true, external-secrets will perform leader election between instances to ensure no more
# than one instance of external-secrets operates at a time.
leaderElect: false

# -- If set external secrets will filter matching
# Secret Stores with the appropriate controller values.
controllerClass: ""

# -- If true external secrets will use recommended kubernetes
# annotations as prometheus metric labels.
extendedMetricLabels: false

# -- If set external secrets are only reconciled in the
# provided namespace
scopedNamespace: ""

# -- Must be used with scopedNamespace. If true, create scoped RBAC roles under the scoped namespace
# and implicitly disable cluster stores and cluster external secrets
scopedRBAC: false

# -- if true, the operator will process cluster external secret. Else, it will ignore them.
processClusterExternalSecret: true

# -- if true, the operator will process cluster store. Else, it will ignore them.
processClusterStore: true

# -- if true, the operator will process push secret. Else, it will ignore them.
processPushSecret: true

# -- Specifies whether an external secret operator deployment be created.
createOperator: true

# -- Specifies the number of concurrent ExternalSecret Reconciles external-secret executes at
# a time.
concurrent: 1

serviceAccount:
  # -- Specifies whether a service account should be created.
  create: true
  # -- Automounts the service account token in all containers of the pod
  automount: true
  # -- Annotations to add to the service account.
  annotations: {}
  # -- Extra Labels to add to the service account.
  extraLabels: {}
  # -- The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template.
  name: ""

rbac:
  # -- Specifies whether role and rolebinding resources should be created.
  create: true

  servicebindings:
    # -- Specifies whether a clusterrole to give servicebindings read access should be created.
    create: true

## -- Extra environment variables to add to container.
extraEnv: []

## -- Map of extra arguments to pass to container.
extraArgs: {}

## -- Extra volumes to pass to pod.
extraVolumes: []

## -- Extra volumes to mount to the container.
extraVolumeMounts: []

## -- Extra containers to add to the pod.
extraContainers: []

# -- Annotations to add to Deployment
deploymentAnnotations: {}

# -- Annotations to add to Pod
podAnnotations: {}

podLabels: {}

podSecurityContext: {}
  # fsGroup: 2000

securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
  seccompProfile:
    type: RuntimeDefault

resources: {}
  # requests:
  #   cpu: 10m
  #   memory: 32Mi

serviceMonitor:
  # -- Specifies whether to create a ServiceMonitor resource for collecting Prometheus metrics
  enabled: false

  # -- namespace where you want to install ServiceMonitors
  namespace: ""

  # -- Additional labels
  additionalLabels: {}

  # --  Interval to scrape metrics
  interval: 30s

  # -- Timeout if metrics can't be retrieved in given time interval
  scrapeTimeout: 25s

  # -- Let prometheus add an exported_ prefix to conflicting labels
  honorLabels: false

  # -- Metric relabel configs to apply to samples before ingestion. [Metric Relabeling](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#metric_relabel_configs)
  metricRelabelings: []
  # - action: replace
  #   regex: (.*)
  #   replacement: $1
  #   sourceLabels:
  #   - exported_namespace
  #   targetLabel: namespace

  # -- Relabel configs to apply to samples before ingestion. [Relabeling](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config)
  relabelings: []
  # - sourceLabels: [__meta_kubernetes_pod_node_name]
  #   separator: ;
  #   regex: ^(.*)$
  #   targetLabel: nodename
  #   replacement: $1
  #   action: replace

metrics:

  listen:
    port: 8080

  service:
    # -- Enable if you use another monitoring tool than Prometheus to scrape the metrics
    enabled: false

    # -- Metrics service port to scrape
    port: 8080

    # -- Additional service annotations
    annotations: {}

nodeSelector: {}

tolerations: []

topologySpreadConstraints: []

affinity: {}

# -- Pod priority class name.
priorityClassName: ""

# -- Pod disruption budget - for more details see https://kubernetes.io/docs/concepts/workloads/pods/disruptions/
podDisruptionBudget:
  enabled: false
  minAvailable: 1
  # maxUnavailable: 1

# -- Run the controller on the host network
hostNetwork: false

webhook:
  # -- Specifies whether a webhook deployment be created.
  create: true
  # -- Specifices the time to check if the cert is valid
  certCheckInterval: "5m"
  # -- Specifices the lookaheadInterval for certificate validity
  lookaheadInterval: ""
  replicaCount: 1

  # -- Specifies the amount of historic ReplicaSets k8s should keep (see https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy)
  revisionHistoryLimit: 10

  certDir: /tmp/certs
  # -- Specifies whether validating webhooks should be created with failurePolicy: Fail or Ignore
  failurePolicy: Fail
  # -- Specifies if webhook pod should use hostNetwork or not.
  hostNetwork: false
  image:
    repository: ghcr.io/external-secrets/external-secrets
    pullPolicy: IfNotPresent
  # -- The image tag to use. The default is the chart appVersion.
    tag: ""
  imagePullSecrets: []
  nameOverride: ""
  fullnameOverride: ""
  # -- The port the webhook will listen to
  port: 10250
  rbac:
  # -- Specifies whether role and rolebinding resources should be created.
    create: true
  serviceAccount:
    # -- Specifies whether a service account should be created.
    create: true
    # -- Automounts the service account token in all containers of the pod
    automount: true
    # -- Annotations to add to the service account.
    annotations: {}
    # -- Extra Labels to add to the service account.
    extraLabels: {}
    # -- The name of the service account to use.
    # If not set and create is true, a name is generated using the fullname template.
    name: ""
  nodeSelector: {}

  certManager:
    # -- Enabling cert-manager support will disable the built in secret and
    # switch to using cert-manager (installed separately) to automatically issue
    # and renew the webhook certificate. This chart does not install
    # cert-manager for you, See https://cert-manager.io/docs/
    enabled: false
    # -- Automatically add the cert-manager.io/inject-ca-from annotation to the
    # webhooks and CRDs. As long as you have the cert-manager CA Injector
    # enabled, this will automatically setup your webhook's CA to the one used
    # by cert-manager. See https://cert-manager.io/docs/concepts/ca-injector
    addInjectorAnnotations: true
    cert:
      # -- Create a certificate resource within this chart. See
      # https://cert-manager.io/docs/usage/certificate/
      create: true
      # -- For the Certificate created by this chart, setup the issuer. See
      # https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.IssuerSpec
      issuerRef:
        group: cert-manager.io
        kind: "Issuer"
        name: "my-issuer"
      # -- Set the requested duration (i.e. lifetime) of the Certificate. See
      # https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.CertificateSpec
      duration: ""
      # -- How long before the currently issued certificate’s expiry
      # cert-manager should renew the certificate. See
      # https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.CertificateSpec
      # Note that renewBefore should be greater than .webhook.lookaheadInterval
      # since the webhook will check this far in advance that the certificate is
      # valid.
      renewBefore: ""
      # -- Add extra annotations to the Certificate resource.
      annotations: {}

  tolerations: []

  topologySpreadConstraints: []

  affinity: {}

    # -- Pod priority class name.
  priorityClassName: ""

  # -- Pod disruption budget - for more details see https://kubernetes.io/docs/concepts/workloads/pods/disruptions/
  podDisruptionBudget:
    enabled: false
    minAvailable: 1
    # maxUnavailable: 1

  metrics:

    listen:
      port: 8080

    service:
      # -- Enable if you use another monitoring tool than Prometheus to scrape the metrics
      enabled: false

      # -- Metrics service port to scrape
      port: 8080

      # -- Additional service annotations
      annotations: {}


  readinessProbe:
    # -- Address for readiness probe
    address: ""
    # -- ReadinessProbe port for kubelet
    port: 8081


    ## -- Extra environment variables to add to container.
  extraEnv: []

    ## -- Map of extra arguments to pass to container.
  extraArgs: {}

    ## -- Extra volumes to pass to pod.
  extraVolumes: []

    ## -- Extra volumes to mount to the container.
  extraVolumeMounts: []

    # -- Annotations to add to Secret
  secretAnnotations: {}

    # -- Annotations to add to Deployment
  deploymentAnnotations: {}

    # -- Annotations to add to Pod
  podAnnotations: {}

  podLabels: {}

  podSecurityContext: {}
      # fsGroup: 2000

  securityContext:
    allowPrivilegeEscalation: false
    capabilities:
      drop:
        - ALL
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    runAsUser: 1000
    seccompProfile:
      type: RuntimeDefault

  resources: {}
      # requests:
      #   cpu: 10m
      #   memory: 32Mi

certController:
  # -- Specifies whether a certificate controller deployment be created.
  create: true
  requeueInterval: "5m"
  replicaCount: 1

  # -- Specifies the amount of historic ReplicaSets k8s should keep (see https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy)
  revisionHistoryLimit: 10

  image:
    repository: ghcr.io/external-secrets/external-secrets
    pullPolicy: IfNotPresent
    tag: ""
  imagePullSecrets: []
  nameOverride: ""
  fullnameOverride: ""
  rbac:
  # -- Specifies whether role and rolebinding resources should be created.
    create: true
  serviceAccount:
    # -- Specifies whether a service account should be created.
    create: true
    # -- Automounts the service account token in all containers of the pod
    automount: true
    # -- Annotations to add to the service account.
    annotations: {}
    # -- Extra Labels to add to the service account.
    extraLabels: {}
    # -- The name of the service account to use.
    # If not set and create is true, a name is generated using the fullname template.
    name: ""
  nodeSelector: {}

  tolerations: []

  topologySpreadConstraints: []

  affinity: {}

  # -- Run the certController on the host network
  hostNetwork: false

    # -- Pod priority class name.
  priorityClassName: ""

  # -- Pod disruption budget - for more details see https://kubernetes.io/docs/concepts/workloads/pods/disruptions/
  podDisruptionBudget:
    enabled: false
    minAvailable: 1
    # maxUnavailable: 1

  metrics:

    listen:
      port: 8080

    service:
      # -- Enable if you use another monitoring tool than Prometheus to scrape the metrics
      enabled: false

      # -- Metrics service port to scrape
      port: 8080

      # -- Additional service annotations
      annotations: {}

  readinessProbe:
    # -- Address for readiness probe
    address: ""
    # -- ReadinessProbe port for kubelet
    port: 8081

    ## -- Extra environment variables to add to container.
  extraEnv: []

    ## -- Map of extra arguments to pass to container.
  extraArgs: {}


    ## -- Extra volumes to pass to pod.
  extraVolumes: []

    ## -- Extra volumes to mount to the container.
  extraVolumeMounts: []

    # -- Annotations to add to Deployment
  deploymentAnnotations: {}

    # -- Annotations to add to Pod
  podAnnotations: {}

  podLabels: {}

  podSecurityContext: {}
      # fsGroup: 2000

  securityContext:
    allowPrivilegeEscalation: false
    capabilities:
      drop:
        - ALL
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    runAsUser: 1000
    seccompProfile:
      type: RuntimeDefault

  resources: {}
      # requests:
      #   cpu: 10m
      #   memory: 32Mi

# -- Specifies `dnsOptions` to deployment
dnsConfig: {}

# -- Any extra pod spec on the deployment
podSpecExtra: {}

