# -- Overrides the chart's name.
nameOverride: ""
# -- Overrides the chart's computed fullname.
fullnameOverride: ""
# -- Additional labels to add into metadata.
additionalLabels: {}
# app: karpenter

# -- Additional annotations to add into metadata.
additionalAnnotations: {}
# -- Image pull policy for Docker images.
imagePullPolicy: IfNotPresent
# -- Image pull secrets for Docker images.
imagePullSecrets: []
serviceAccount:
  # -- Specifies if a ServiceAccount should be created.
  create: true
  # -- The name of the ServiceAccount to use.
  # If not set and create is true, a name is generated using the fullname template.
  name: ""
  # -- Additional annotations for the ServiceAccount.
  annotations: {}
# -- Specifies additional rules for the core ClusterRole.
additionalClusterRoleRules: []
serviceMonitor:
  # -- Specifies whether a ServiceMonitor should be created.
  enabled: false
  # -- Additional labels for the ServiceMonitor.
  additionalLabels: {}
  # -- Configuration on `http-metrics` endpoint for the ServiceMonitor. 
  # Not to be used to add additional endpoints. 
  # See the Prometheus operator documentation for configurable fields https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#endpoint
  endpointConfig: {}
# -- Number of replicas.
replicas: 2
# -- The number of old ReplicaSets to retain to allow rollback.
revisionHistoryLimit: 10
# -- Strategy for updating the pod.
strategy:
  rollingUpdate:
    maxUnavailable: 1
# -- Additional labels for the pod.
podLabels: {}
# -- Additional annotations for the pod.
podAnnotations: {}
podDisruptionBudget:
  name: karpenter
  maxUnavailable: 1
# -- SecurityContext for the pod.
podSecurityContext:
  fsGroup: 65532
# -- PriorityClass name for the pod.
priorityClassName: system-cluster-critical
# -- Override the default termination grace period for the pod.
terminationGracePeriodSeconds:
# -- Bind the pod to the host network.
# This is required when using a custom CNI.
hostNetwork: false
# -- Configure the DNS Policy for the pod
dnsPolicy: ClusterFirst
# -- Configure DNS Config for the pod
dnsConfig: {}
#  options:
#    - name: ndots
#      value: "1"
# -- Node selectors to schedule the pod to nodes with labels.
nodeSelector:
  kubernetes.io/os: linux
# -- Affinity rules for scheduling the pod. If an explicit label selector is not provided for pod affinity or pod anti-affinity one will be created from the pod selector labels.
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: karpenter.sh/nodepool
              operator: DoesNotExist
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - topologyKey: "kubernetes.io/hostname"
# -- Topology spread constraints to increase the controller resilience by distributing pods across the cluster zones. If an explicit label selector is not provided one will be created from the pod selector labels.
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: ScheduleAnyway
# -- Tolerations to allow the pod to be scheduled to nodes with taints.
tolerations:
  - key: CriticalAddonsOnly
    operator: Exists
# -- Additional volumes for the pod.
extraVolumes: []
# - name: aws-iam-token
#   projected:
#     defaultMode: 420
#     sources:
#     - serviceAccountToken:
#         audience: sts.amazonaws.com
#         expirationSeconds: 86400
#         path: token
controller:
  image:
    # -- Repository path to the controller image.
    repository: public.ecr.aws/karpenter/controller
    # -- Tag of the controller image.
    tag: 0.37.0
    # -- SHA256 digest of the controller image.
    digest: sha256:157f478f5db1fe999f5e2d27badcc742bf51cc470508b3cebe78224d0947674f
  # -- Additional environment variables for the controller pod.
  env: []
  # - name: AWS_REGION
  #   value: eu-west-1
  envFrom: []
  # -- Resources for the controller pod.
  resources: {}
  # We usually recommend not to specify default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  #  requests:
  #    cpu: 1
  #    memory: 1Gi
  #  limits:
  #    cpu: 1
  #    memory: 1Gi

  # -- Additional volumeMounts for the controller pod.
  extraVolumeMounts: []
  # - name: aws-iam-token
  #   mountPath: /var/run/secrets/eks.amazonaws.com/serviceaccount
  #   readOnly: true
  # -- Additional sidecarContainer config
  sidecarContainer: []
  # -- Additional volumeMounts for the sidecar - this will be added to the volume mounts on top of extraVolumeMounts
  sidecarVolumeMounts: []
  metrics:
    # -- The container port to use for metrics.
    port: 8000
  healthProbe:
    # -- The container port to use for http health probe.
    port: 8081
webhook:
  # -- Whether to enable the webhooks and webhook permissions.
  enabled: false
  # -- The container port to use for the webhook.
  port: 8443
  metrics:
    # -- The container port to use for webhook metrics.
    port: 8001
# -- Global log level, defaults to 'info'
logLevel: info
# -- Log configuration (Deprecated: Logging configuration will be dropped by v1, use logLevel instead)
logConfig:
  # -- Whether to enable provisioning and mounting the log ConfigMap
  enabled: false
  # -- Log outputPaths - defaults to stdout only
  outputPaths:
    - stdout
  # -- Log errorOutputPaths - defaults to stderr only
  errorOutputPaths:
    - stderr
  # -- Log encoding - defaults to json - must be one of 'json', 'console'
  logEncoding: json
  # -- Component-based log configuration
  logLevel:
    # -- Global log level, defaults to 'info'
    global: info
    # -- Controller log level, defaults to 'info'
    controller: info
    # -- Error log level, defaults to 'error'
    webhook: error
# -- Global Settings to configure Karpenter
settings:
  # -- The maximum length of a batch window. The longer this is, the more pods we can consider for provisioning at one
  # time which usually results in fewer but larger nodes.
  batchMaxDuration: 10s
  # -- The maximum amount of time with no new ending pods that if exceeded ends the current batching window. If pods arrive
  # faster than this time, the batching window will be extended up to the maxDuration. If they arrive slower, the pods
  # will be batched separately.
  batchIdleDuration: 1s
  # -- Role to assume for calling AWS services.
  assumeRoleARN: ""
  # -- Duration of assumed credentials in minutes. Default value is 15 minutes. Not used unless assumeRoleARN set.
  assumeRoleDuration: 15m
  # -- Cluster CA bundle for TLS configuration of provisioned nodes. If not set, this is taken from the controller's TLS configuration for the API server.
  clusterCABundle: ""
  # -- Cluster name.
  clusterName: ""
  # -- Cluster endpoint. If not set, will be discovered during startup (EKS only)
  clusterEndpoint: ""
  # -- If true then assume we can't reach AWS services which don't have a VPC endpoint
  # This also has the effect of disabling look-ups to the AWS pricing endpoint
  isolatedVPC: false
  # -- The VM memory overhead as a percent that will be subtracted from the total memory for all instance types
  vmMemoryOverheadPercent: 0.075
  # -- Interruption queue is the name of the SQS queue used for processing interruption events from EC2
  # Interruption handling is disabled if not specified. Enabling interruption handling may
  # require additional permissions on the controller service account. Additional permissions are outlined in the docs.
  interruptionQueue: ""
  # -- Reserved ENIs are not included in the calculations for max-pods or kube-reserved
  # This is most often used in the VPC CNI custom networking setup https://docs.aws.amazon.com/eks/latest/userguide/cni-custom-network.html
  reservedENIs: "0"
  # -- Feature Gate configuration values. Feature Gates will follow the same graduation process and requirements as feature gates
  # in Kubernetes. More information here https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/#feature-gates-for-alpha-or-beta-features
  featureGates:
    # -- drift is in BETA and is enabled by default.
    # Setting drift to false disables the drift disruption method to watch for drift between currently deployed nodes
    # and the desired state of nodes set in nodepools and nodeclasses
    drift: true
    # -- spotToSpotConsolidation is ALPHA and is disabled by default.
    # Setting this to true will enable spot replacement consolidation for both single and multi-node consolidation.
    spotToSpotConsolidation: false

