# Default values for kube-prometheus-stack.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

## Provide a name in place of kube-prometheus-stack for `app:` labels
##
nameOverride: ""

## Override the deployment namespace
##
namespaceOverride: ""

## Provide a k8s version to auto dashboard import script example: kubeTargetVersionOverride: 1.26.6
##
kubeTargetVersionOverride: ""

## Allow kubeVersion to be overridden while creating the ingress
##
kubeVersionOverride: ""

## Provide a name to substitute for the full names of resources
##
fullnameOverride: ""

## Labels to apply to all resources
##
commonLabels: {}
# scmhash: abc123
# myLabel: aakkmd

## Install Prometheus Operator CRDs
##
crds:
  enabled: true

## Create default rules for monitoring the cluster
##
defaultRules:
  create: true
  rules:
    alertmanager: true
    etcd: true
    configReloaders: true
    general: true
    k8sContainerCpuUsageSecondsTotal: true
    k8sContainerMemoryCache: true
    k8sContainerMemoryRss: true
    k8sContainerMemorySwap: true
    k8sContainerResource: true
    k8sPodOwner: true
    kubeApiserverAvailability: true
    kubeApiserverBurnrate: true
    kubeApiserverHistogram: true
    kubeApiserverSlos: true
    kubeControllerManager: true
    kubelet: true
    kubeProxy: true
    kubePrometheusGeneral: true
    kubePrometheusNodeRecording: true
    kubernetesApps: true
    kubernetesResources: true
    kubernetesStorage: true
    kubernetesSystem: true
    kubeSchedulerAlerting: true
    kubeSchedulerRecording: true
    kubeStateMetrics: true
    network: true
    node: true
    nodeExporterAlerting: true
    nodeExporterRecording: true
    prometheus: true
    prometheusOperator: true
    windows: true

  ## Reduce app namespace alert scope
  appNamespacesTarget: ".*"

  ## Set keep_firing_for for all alerts
  keepFiringFor: ""

  ## Labels for default rules
  labels: {}
  ## Annotations for default rules
  annotations: {}

  ## Additional labels for PrometheusRule alerts
  additionalRuleLabels: {}

  ## Additional annotations for PrometheusRule alerts
  additionalRuleAnnotations: {}

  ## Additional labels for specific PrometheusRule alert groups
  additionalRuleGroupLabels:
    alertmanager: {}
    etcd: {}
    configReloaders: {}
    general: {}
    k8sContainerCpuUsageSecondsTotal: {}
    k8sContainerMemoryCache: {}
    k8sContainerMemoryRss: {}
    k8sContainerMemorySwap: {}
    k8sContainerResource: {}
    k8sPodOwner: {}
    kubeApiserverAvailability: {}
    kubeApiserverBurnrate: {}
    kubeApiserverHistogram: {}
    kubeApiserverSlos: {}
    kubeControllerManager: {}
    kubelet: {}
    kubeProxy: {}
    kubePrometheusGeneral: {}
    kubePrometheusNodeRecording: {}
    kubernetesApps: {}
    kubernetesResources: {}
    kubernetesStorage: {}
    kubernetesSystem: {}
    kubeSchedulerAlerting: {}
    kubeSchedulerRecording: {}
    kubeStateMetrics: {}
    network: {}
    node: {}
    nodeExporterAlerting: {}
    nodeExporterRecording: {}
    prometheus: {}
    prometheusOperator: {}

  ## Additional annotations for specific PrometheusRule alerts groups
  additionalRuleGroupAnnotations:
    alertmanager: {}
    etcd: {}
    configReloaders: {}
    general: {}
    k8sContainerCpuUsageSecondsTotal: {}
    k8sContainerMemoryCache: {}
    k8sContainerMemoryRss: {}
    k8sContainerMemorySwap: {}
    k8sContainerResource: {}
    k8sPodOwner: {}
    kubeApiserverAvailability: {}
    kubeApiserverBurnrate: {}
    kubeApiserverHistogram: {}
    kubeApiserverSlos: {}
    kubeControllerManager: {}
    kubelet: {}
    kubeProxy: {}
    kubePrometheusGeneral: {}
    kubePrometheusNodeRecording: {}
    kubernetesApps: {}
    kubernetesResources: {}
    kubernetesStorage: {}
    kubernetesSystem: {}
    kubeSchedulerAlerting: {}
    kubeSchedulerRecording: {}
    kubeStateMetrics: {}
    network: {}
    node: {}
    nodeExporterAlerting: {}
    nodeExporterRecording: {}
    prometheus: {}
    prometheusOperator: {}

  additionalAggregationLabels: []

  ## Prefix for runbook URLs. Use this to override the first part of the runbookURLs that is common to all rules.
  runbookUrl: "https://runbooks.prometheus-operator.dev/runbooks"

  ## Disabled PrometheusRule alerts
  disabled: {}
  # KubeAPIDown: true
  # NodeRAIDDegraded: true

## Deprecated way to provide custom recording or alerting rules to be deployed into the cluster.
##
# additionalPrometheusRules: []
#  - name: my-rule-file
#    groups:
#      - name: my_group
#        rules:
#        - record: my_record
#          expr: 100 * my_record

## Provide custom recording or alerting rules to be deployed into the cluster.
##
additionalPrometheusRulesMap: {}
#  rule-name:
#    groups:
#    - name: my_group
#      rules:
#      - record: my_record
#        expr: 100 * my_record

##
global:
  rbac:
    create: true

    ## Create ClusterRoles that extend the existing view, edit and admin ClusterRoles to interact with prometheus-operator CRDs
    ## Ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles
    createAggregateClusterRoles: false
    pspEnabled: false
    pspAnnotations: {}
      ## Specify pod annotations
      ## Ref: https://kubernetes.io/docs/concepts/policy/pod-security-policy/#apparmor
      ## Ref: https://kubernetes.io/docs/concepts/policy/pod-security-policy/#seccomp
      ## Ref: https://kubernetes.io/docs/concepts/policy/pod-security-policy/#sysctl
      ##
      # seccomp.security.alpha.kubernetes.io/allowedProfileNames: '*'
      # seccomp.security.alpha.kubernetes.io/defaultProfileName: 'docker/default'
      # apparmor.security.beta.kubernetes.io/defaultProfileName: 'runtime/default'

  ## Global image registry to use if it needs to be overriden for some specific use cases (e.g local registries, custom images, ...)
  ##
  imageRegistry: ""

  ## Reference to one or more secrets to be used when pulling images
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
  ##
  imagePullSecrets: []
  # - name: "image-pull-secret"
  # or
  # - "image-pull-secret"

windowsMonitoring:
  ## Deploys the windows-exporter and Windows-specific dashboards and rules (job name must be 'windows-exporter')
  enabled: false

## Configuration for prometheus-windows-exporter
## ref: https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-windows-exporter
##
prometheus-windows-exporter:
  ## Enable ServiceMonitor and set Kubernetes label to use as a job label
  ##
  prometheus:
    monitor:
      enabled: true
      jobLabel: jobLabel

  ## Set job label to 'windows-exporter' as required by the default Prometheus rules and Grafana dashboards
  ##
  podLabels:
    jobLabel: windows-exporter

  ## Enable memory and container metrics as required by the default Prometheus rules and Grafana dashboards
  ##
  config: |-
    collectors:
      enabled: '[defaults],memory,container'

## Configuration for alertmanager
## ref: https://prometheus.io/docs/alerting/alertmanager/
##
alertmanager:

  ## Deploy alertmanager
  ##
  enabled: true

  ## Annotations for Alertmanager
  ##
  annotations: {}

  ## Api that prometheus will use to communicate with alertmanager. Possible values are v1, v2
  ##
  apiVersion: v2

  ## Service account for Alertmanager to use.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
  ##
  serviceAccount:
    create: true
    name: ""
    annotations: {}
    automountServiceAccountToken: true

  ## Configure pod disruption budgets for Alertmanager
  ## ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/#specifying-a-poddisruptionbudget
  ## This configuration is immutable once created and will require the PDB to be deleted to be changed
  ## https://github.com/kubernetes/kubernetes/issues/45398
  ##
  podDisruptionBudget:
    enabled: false
    minAvailable: 1
    maxUnavailable: ""

  ## Alertmanager configuration directives
  ## ref: https://prometheus.io/docs/alerting/configuration/#configuration-file
  ##      https://prometheus.io/webtools/alerting/routing-tree-editor/
  ##
  config:
    global:
      resolve_timeout: 5m
    inhibit_rules:
      - source_matchers:
          - 'severity = critical'
        target_matchers:
          - 'severity =~ warning|info'
        equal:
          - 'namespace'
          - 'alertname'
      - source_matchers:
          - 'severity = warning'
        target_matchers:
          - 'severity = info'
        equal:
          - 'namespace'
          - 'alertname'
      - source_matchers:
          - 'alertname = InfoInhibitor'
        target_matchers:
          - 'severity = info'
        equal:
          - 'namespace'
    route:
      group_by: ['namespace']
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 12h
      receiver: 'null'
      routes:
      - receiver: 'null'
        matchers:
          - alertname =~ "InfoInhibitor|Watchdog"
    receivers:
    - name: 'null'
    templates:
    - '/etc/alertmanager/config/*.tmpl'

  ## Alertmanager configuration directives (as string type, preferred over the config hash map)
  ## stringConfig will be used only, if tplConfig is true
  ## ref: https://prometheus.io/docs/alerting/configuration/#configuration-file
  ##      https://prometheus.io/webtools/alerting/routing-tree-editor/
  ##
  stringConfig: ""

  ## Pass the Alertmanager configuration directives through Helm's templating
  ## engine. If the Alertmanager configuration contains Alertmanager templates,
  ## they'll need to be properly escaped so that they are not interpreted by
  ## Helm
  ## ref: https://helm.sh/docs/developing_charts/#using-the-tpl-function
  ##      https://prometheus.io/docs/alerting/configuration/#tmpl_string
  ##      https://prometheus.io/docs/alerting/notifications/
  ##      https://prometheus.io/docs/alerting/notification_examples/
  tplConfig: false

  ## Alertmanager template files to format alerts
  ## By default, templateFiles are placed in /etc/alertmanager/config/ and if
  ## they have a .tmpl file suffix will be loaded. See config.templates above
  ## to change, add other suffixes. If adding other suffixes, be sure to update
  ## config.templates above to include those suffixes.
  ## ref: https://prometheus.io/docs/alerting/notifications/
  ##      https://prometheus.io/docs/alerting/notification_examples/
  ##
  templateFiles: {}
  #
  ## An example template:
  #   template_1.tmpl: |-
  #       {{ define "cluster" }}{{ .ExternalURL | reReplaceAll ".*alertmanager\\.(.*)" "$1" }}{{ end }}
  #
  #       {{ define "slack.myorg.text" }}
  #       {{- $root := . -}}
  #       {{ range .Alerts }}
  #         *Alert:* {{ .Annotations.summary }} - `{{ .Labels.severity }}`
  #         *Cluster:* {{ template "cluster" $root }}
  #         *Description:* {{ .Annotations.description }}
  #         *Graph:* <{{ .GeneratorURL }}|:chart_with_upwards_trend:>
  #         *Runbook:* <{{ .Annotations.runbook }}|:spiral_note_pad:>
  #         *Details:*
  #           {{ range .Labels.SortedPairs }} - *{{ .Name }}:* `{{ .Value }}`
  #           {{ end }}
  #       {{ end }}
  #       {{ end }}

  ingress:
    enabled: false

    # For Kubernetes >= 1.18 you should specify the ingress-controller via the field ingressClassName
    # See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#specifying-the-class-of-an-ingress
    # ingressClassName: nginx

    annotations: {}

    labels: {}

    ## Override ingress to a different defined port on the service
    # servicePort: 8081
    ## Override ingress to a different service then the default, this is useful if you need to
    ## point to a specific instance of the alertmanager (eg kube-prometheus-stack-alertmanager-0)
    # serviceName: kube-prometheus-stack-alertmanager-0

    ## Hosts must be provided if Ingress is enabled.
    ##
    hosts: []
      # - alertmanager.domain.com

    ## Paths to use for ingress rules - one path should match the alertmanagerSpec.routePrefix
    ##
    paths: []
    # - /

    ## For Kubernetes >= 1.18 you should specify the pathType (determines how Ingress paths should be matched)
    ## See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#better-path-matching-with-path-types
    # pathType: ImplementationSpecific

    ## TLS configuration for Alertmanager Ingress
    ## Secret must be manually created in the namespace
    ##
    tls: []
    # - secretName: alertmanager-general-tls
    #   hosts:
    #   - alertmanager.example.com

  ## Configuration for Alertmanager secret
  ##
  secret:
    annotations: {}

  ## Configuration for creating an Ingress that will map to each Alertmanager replica service
  ## alertmanager.servicePerReplica must be enabled
  ##
  ingressPerReplica:
    enabled: false

    # For Kubernetes >= 1.18 you should specify the ingress-controller via the field ingressClassName
    # See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#specifying-the-class-of-an-ingress
    # ingressClassName: nginx

    annotations: {}
    labels: {}

    ## Final form of the hostname for each per replica ingress is
    ## {{ ingressPerReplica.hostPrefix }}-{{ $replicaNumber }}.{{ ingressPerReplica.hostDomain }}
    ##
    ## Prefix for the per replica ingress that will have `-$replicaNumber`
    ## appended to the end
    hostPrefix: ""
    ## Domain that will be used for the per replica ingress
    hostDomain: ""

    ## Paths to use for ingress rules
    ##
    paths: []
    # - /

    ## For Kubernetes >= 1.18 you should specify the pathType (determines how Ingress paths should be matched)
    ## See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#better-path-matching-with-path-types
    # pathType: ImplementationSpecific

    ## Secret name containing the TLS certificate for alertmanager per replica ingress
    ## Secret must be manually created in the namespace
    tlsSecretName: ""

    ## Separated secret for each per replica Ingress. Can be used together with cert-manager
    ##
    tlsSecretPerReplica:
      enabled: false
      ## Final form of the secret for each per replica ingress is
      ## {{ tlsSecretPerReplica.prefix }}-{{ $replicaNumber }}
      ##
      prefix: "alertmanager"

  ## Configuration for Alertmanager service
  ##
  service:
    annotations: {}
    labels: {}
    clusterIP: ""

    ## Port for Alertmanager Service to listen on
    ##
    port: 9093
    ## To be used with a proxy extraContainer port
    ##
    targetPort: 9093
    ## Port to expose on each node
    ## Only used if service.type is 'NodePort'
    ##
    nodePort: 30903
    ## List of IP addresses at which the Prometheus server service is available
    ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
    ##

    ## Additional ports to open for Alertmanager service
    ##
    additionalPorts: []
    # - name: oauth-proxy
    #   port: 8081
    #   targetPort: 8081
    # - name: oauth-metrics
    #   port: 8082
    #   targetPort: 8082

    externalIPs: []
    loadBalancerIP: ""
    loadBalancerSourceRanges: []

    ## Denotes if this Service desires to route external traffic to node-local or cluster-wide endpoints
    ##
    externalTrafficPolicy: Cluster

    ## If you want to make sure that connections from a particular client are passed to the same Pod each time
    ## Accepts 'ClientIP' or ''
    ##
    sessionAffinity: ""

    ## Service type
    ##
    type: ClusterIP

  ## Configuration for creating a separate Service for each statefulset Alertmanager replica
  ##
  servicePerReplica:
    enabled: false
    annotations: {}

    ## Port for Alertmanager Service per replica to listen on
    ##
    port: 9093

    ## To be used with a proxy extraContainer port
    targetPort: 9093

    ## Port to expose on each node
    ## Only used if servicePerReplica.type is 'NodePort'
    ##
    nodePort: 30904

    ## Loadbalancer source IP ranges
    ## Only used if servicePerReplica.type is "LoadBalancer"
    loadBalancerSourceRanges: []

    ## Denotes if this Service desires to route external traffic to node-local or cluster-wide endpoints
    ##
    externalTrafficPolicy: Cluster

    ## Service type
    ##
    type: ClusterIP

  ## If true, create a serviceMonitor for alertmanager
  ##
  serviceMonitor:
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""
    selfMonitor: true

    ## Additional labels
    ##
    additionalLabels: {}

    ## SampleLimit defines per-scrape limit on number of scraped samples that will be accepted.
    ##
    sampleLimit: 0

    ## TargetLimit defines a limit on the number of scraped targets that will be accepted.
    ##
    targetLimit: 0

    ## Per-scrape limit on number of labels that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelLimit: 0

    ## Per-scrape limit on length of labels name that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelNameLengthLimit: 0

    ## Per-scrape limit on length of labels value that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelValueLengthLimit: 0

    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""

    ## scheme: HTTP scheme to use for scraping. Can be used with `tlsConfig` for example if using istio mTLS.
    scheme: ""

    ## enableHttp2: Whether to enable HTTP2.
    ## See https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#endpoint
    enableHttp2: true

    ## tlsConfig: TLS configuration to use when scraping the endpoint. For example if using istio mTLS.
    ## Of type: https://github.com/coreos/prometheus-operator/blob/main/Documentation/api.md#tlsconfig
    tlsConfig: {}

    bearerTokenFile:

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## Additional Endpoints
    ##
    additionalEndpoints: []
    # - port: oauth-metrics
    #   path: /metrics

  ## Settings affecting alertmanagerSpec
  ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#alertmanagerspec
  ##
  alertmanagerSpec:
    ## Standard object's metadata. More info: https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md#metadata
    ## Metadata Labels and Annotations gets propagated to the Alertmanager pods.
    ##
    podMetadata: {}

    ## Image of Alertmanager
    ##
    image:
      registry: quay.io
      repository: prometheus/alertmanager
      tag: v0.26.0
      sha: ""

    ## If true then the user will be responsible to provide a secret with alertmanager configuration
    ## So when true the config part will be ignored (including templateFiles) and the one in the secret will be used
    ##
    useExistingSecret: false

    ## Secrets is a list of Secrets in the same namespace as the Alertmanager object, which shall be mounted into the
    ## Alertmanager Pods. The Secrets are mounted into /etc/alertmanager/secrets/.
    ##
    secrets: []

    ## ConfigMaps is a list of ConfigMaps in the same namespace as the Alertmanager object, which shall be mounted into the Alertmanager Pods.
    ## The ConfigMaps are mounted into /etc/alertmanager/configmaps/.
    ##
    configMaps: []

    ## ConfigSecret is the name of a Kubernetes Secret in the same namespace as the Alertmanager object, which contains configuration for
    ## this Alertmanager instance. Defaults to 'alertmanager-' The secret is mounted into /etc/alertmanager/config.
    ##
    # configSecret:

    ## WebTLSConfig defines the TLS parameters for HTTPS
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#alertmanagerwebspec
    web: {}

    ## AlertmanagerConfigs to be selected to merge and configure Alertmanager with.
    ##
    alertmanagerConfigSelector: {}
    ## Example which selects all alertmanagerConfig resources
    ## with label "alertconfig" with values any of "example-config" or "example-config-2"
    # alertmanagerConfigSelector:
    #   matchExpressions:
    #     - key: alertconfig
    #       operator: In
    #       values:
    #         - example-config
    #         - example-config-2
    #
    ## Example which selects all alertmanagerConfig resources with label "role" set to "example-config"
    # alertmanagerConfigSelector:
    #   matchLabels:
    #     role: example-config

    ## Namespaces to be selected for AlertmanagerConfig discovery. If nil, only check own namespace.
    ##
    alertmanagerConfigNamespaceSelector: {}
    ## Example which selects all namespaces
    ## with label "alertmanagerconfig" with values any of "example-namespace" or "example-namespace-2"
    # alertmanagerConfigNamespaceSelector:
    #   matchExpressions:
    #     - key: alertmanagerconfig
    #       operator: In
    #       values:
    #         - example-namespace
    #         - example-namespace-2

    ## Example which selects all namespaces with label "alertmanagerconfig" set to "enabled"
    # alertmanagerConfigNamespaceSelector:
    #   matchLabels:
    #     alertmanagerconfig: enabled

    ## AlermanagerConfig to be used as top level configuration
    ##
    alertmanagerConfiguration: {}
    ## Example with select a global alertmanagerconfig
    # alertmanagerConfiguration:
    #   name: global-alertmanager-Configuration

    ## Defines the strategy used by AlertmanagerConfig objects to match alerts. eg:
    ##
    alertmanagerConfigMatcherStrategy: {}
    ## Example with use OnNamespace strategy
    # alertmanagerConfigMatcherStrategy:
    #   type: OnNamespace

    ## Define Log Format
    # Use logfmt (default) or json logging
    logFormat: logfmt

    ## Log level for Alertmanager to be configured with.
    ##
    logLevel: info

    ## Size is the expected size of the alertmanager cluster. The controller will eventually make the size of the
    ## running cluster equal to the expected size.
    replicas: 1

    ## Time duration Alertmanager shall retain data for. Default is '120h', and must match the regular expression
    ## [0-9]+(ms|s|m|h) (milliseconds seconds minutes hours).
    ##
    retention: 120h

    ## Storage is the definition of how storage will be used by the Alertmanager instances.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/storage.md
    ##
    storage: {}
    # volumeClaimTemplate:
    #   spec:
    #     storageClassName: gluster
    #     accessModes: ["ReadWriteOnce"]
    #     resources:
    #       requests:
    #         storage: 50Gi
    #     selector: {}


    ## The external URL the Alertmanager instances will be available under. This is necessary to generate correct URLs. This is necessary if Alertmanager is not served from root of a DNS name. string  false
    ##
    externalUrl:

    ## The route prefix Alertmanager registers HTTP handlers for. This is useful, if using ExternalURL and a proxy is rewriting HTTP routes of a request, and the actual ExternalURL is still true,
    ## but the server serves requests under a different route prefix. For example for use with kubectl proxy.
    ##
    routePrefix: /

    ## scheme: HTTP scheme to use. Can be used with `tlsConfig` for example if using istio mTLS.
    scheme: ""

    ## tlsConfig: TLS configuration to use when connect to the endpoint. For example if using istio mTLS.
    ## Of type: https://github.com/coreos/prometheus-operator/blob/main/Documentation/api.md#tlsconfig
    tlsConfig: {}

    ## If set to true all actions on the underlying managed objects are not going to be performed, except for delete actions.
    ##
    paused: false

    ## Define which Nodes the Pods are scheduled on.
    ## ref: https://kubernetes.io/docs/user-guide/node-selection/
    ##
    nodeSelector: {}

    ## Define resources requests and limits for single Pods.
    ## ref: https://kubernetes.io/docs/user-guide/compute-resources/
    ##
    resources: {}
    # requests:
    #   memory: 400Mi

    ## Pod anti-affinity can prevent the scheduler from placing Prometheus replicas on the same node.
    ## The default value "soft" means that the scheduler should *prefer* to not schedule two replica pods onto the same node but no guarantee is provided.
    ## The value "hard" means that the scheduler is *required* to not schedule two replica pods onto the same node.
    ## The value "" will disable pod anti-affinity so that no anti-affinity rules will be configured.
    ##
    podAntiAffinity: ""

    ## If anti-affinity is enabled sets the topologyKey to use for anti-affinity.
    ## This can be changed to, for example, failure-domain.beta.kubernetes.io/zone
    ##
    podAntiAffinityTopologyKey: kubernetes.io/hostname

    ## Assign custom affinity rules to the alertmanager instance
    ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
    ##
    affinity: {}
    # nodeAffinity:
    #   requiredDuringSchedulingIgnoredDuringExecution:
    #     nodeSelectorTerms:
    #     - matchExpressions:
    #       - key: kubernetes.io/e2e-az-name
    #         operator: In
    #         values:
    #         - e2e-az1
    #         - e2e-az2

    ## If specified, the pod's tolerations.
    ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
    ##
    tolerations: []
    # - key: "key"
    #   operator: "Equal"
    #   value: "value"
    #   effect: "NoSchedule"

    ## If specified, the pod's topology spread constraints.
    ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
    ##
    topologySpreadConstraints: []
    # - maxSkew: 1
    #   topologyKey: topology.kubernetes.io/zone
    #   whenUnsatisfiable: DoNotSchedule
    #   labelSelector:
    #     matchLabels:
    #       app: alertmanager

    ## SecurityContext holds pod-level security attributes and common container settings.
    ## This defaults to non root user with uid 1000 and gid 2000. *v1.PodSecurityContext  false
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
    ##
    securityContext:
      runAsGroup: 2000
      runAsNonRoot: true
      runAsUser: 1000
      fsGroup: 2000
      seccompProfile:
        type: RuntimeDefault

    ## ListenLocal makes the Alertmanager server listen on loopback, so that it does not bind against the Pod IP.
    ## Note this is only for the Alertmanager UI, not the gossip communication.
    ##
    listenLocal: false

    ## Containers allows injecting additional containers. This is meant to allow adding an authentication proxy to an Alertmanager pod.
    ##
    containers: []
    # containers:
    # - name: oauth-proxy
    #   image: quay.io/oauth2-proxy/oauth2-proxy:v7.5.1
    #   args:
    #   - --upstream=http://127.0.0.1:9093
    #   - --http-address=0.0.0.0:8081
    #   - --metrics-address=0.0.0.0:8082
    #   - ...
    #   ports:
    #   - containerPort: 8081
    #     name: oauth-proxy
    #     protocol: TCP
    #   - containerPort: 8082
    #     name: oauth-metrics
    #     protocol: TCP
    #   resources: {}

    # Additional volumes on the output StatefulSet definition.
    volumes: []

    # Additional VolumeMounts on the output StatefulSet definition.
    volumeMounts: []

    ## InitContainers allows injecting additional initContainers. This is meant to allow doing some changes
    ## (permissions, dir tree) on mounted volumes before starting prometheus
    initContainers: []

    ## Priority class assigned to the Pods
    ##
    priorityClassName: ""

    ## AdditionalPeers allows injecting a set of additional Alertmanagers to peer with to form a highly available cluster.
    ##
    additionalPeers: []

    ## PortName to use for Alert Manager.
    ##
    portName: "http-web"

    ## ClusterAdvertiseAddress is the explicit address to advertise in cluster. Needs to be provided for non RFC1918 [1] (public) addresses. [1] RFC1918: https://tools.ietf.org/html/rfc1918
    ##
    clusterAdvertiseAddress: false

    ## clusterGossipInterval determines interval between gossip attempts.
    ## Needs to be specified as GoDuration, a time duration that can be parsed by Go’s time.ParseDuration() (e.g. 45ms, 30s, 1m, 1h20m15s)
    clusterGossipInterval: ""

    ## clusterPeerTimeout determines timeout for cluster peering.
    ## Needs to be specified as GoDuration, a time duration that can be parsed by Go’s time.ParseDuration() (e.g. 45ms, 30s, 1m, 1h20m15s)
    clusterPeerTimeout: ""

    ## clusterPushpullInterval determines interval between pushpull attempts.
    ## Needs to be specified as GoDuration, a time duration that can be parsed by Go’s time.ParseDuration() (e.g. 45ms, 30s, 1m, 1h20m15s)
    clusterPushpullInterval: ""

    ## ForceEnableClusterMode ensures Alertmanager does not deactivate the cluster mode when running with a single replica.
    ## Use case is e.g. spanning an Alertmanager cluster across Kubernetes clusters with a single replica in each.
    forceEnableClusterMode: false

    ## Minimum number of seconds for which a newly created pod should be ready without any of its container crashing for it to
    ## be considered available. Defaults to 0 (pod will be considered available as soon as it is ready).
    minReadySeconds: 0

    ## Additional configuration which is not covered by the properties above. (passed through tpl)
    additionalConfig: {}

    ## Additional configuration which is not covered by the properties above.
    ## Useful, if you need advanced templating inside alertmanagerSpec.
    ## Otherwise, use alertmanager.alertmanagerSpec.additionalConfig (passed through tpl)
    additionalConfigString: ""

  ## ExtraSecret can be used to store various data in an extra secret
  ## (use it for example to store hashed basic auth credentials)
  extraSecret:
    ## if not set, name will be auto generated
    # name: ""
    annotations: {}
    data: {}
  #   auth: |
  #     foo:$apr1$OFG3Xybp$ckL0FHDAkoXYIlH9.cysT0
  #     someoneelse:$apr1$DMZX2Z4q$6SbQIfyuLQd.xmo/P0m2c.

## Using default values from https://github.com/grafana/helm-charts/blob/main/charts/grafana/values.yaml
##
grafana:
  enabled: true
  grafana.ini:
    check_for_updates: false
    reporting_enabled: false
    server:
      domain: grafana-lasdpc.icmc.usp.br
      root_url: https://grafana-lasdpc.icmc.usp.br
    security:
      disable_gravatar: true
    dashboards:
      min_refresh_interval: 60s
    auth:
      disable_login_form: true
    users:
    editors_can_admin: true
    auto_assign_org_role: Admin
    auth.github:
      enabled: true
      auto_login: false
      client_id: "${client_id}"
      client_secret: "${client_secret}"
      role_attribute_path = [login=='octocat'][0] && 'GrafanaAdmin' || 'Admin'
      scopes: user:email, read:org
      auth_url: https://github.com/login/oauth/authorize
      token_url: https://github.com/login/oauth/access_token
      api_url: https://api.github.com/user
      allowed_organizations: lasdpc-icmc
      allow_sign_up: true
  persistence:
    enabled: true
    type: pvc
    storageClassName: gp2
    accessModes:
    - ReadWriteOnce
    size: 30Gi
    finalizers:
    - kubernetes.io/pvc-protection  
  enabled: true
  namespaceOverride: ""
  namespaceOverride: ""
  plugins:
    - grafana-polystat-panel

  ## ForceDeployDatasources Create datasource configmap even if grafana deployment has been disabled
  ##
  forceDeployDatasources: false

  ## ForceDeployDashboard Create dashboard configmap even if grafana deployment has been disabled
  ##
  forceDeployDashboards: false

  ## Deploy default dashboards
  ##
  defaultDashboardsEnabled: true

  ## Timezone for the default dashboards
  ## Other options are: browser or a specific timezone, i.e. Europe/Luxembourg
  ##
  defaultDashboardsTimezone: utc

  adminPassword: prom-operator

  rbac:
    ## If true, Grafana PSPs will be created
    ##
    pspEnabled: false

  ingress:
    ## If true, Grafana Ingress will be created
    ##
    enabled: true

    ## IngressClassName for Grafana Ingress.
    ## Should be provided if Ingress is enable.
    ##
    # ingressClassName: nginx

    ## Annotations for Grafana Ingress
    ##
    annotations:
      kubernetes.io/ingress.class: nginx
      kubernetes.io/tls-acme: "true"

    ## Labels to be added to the Ingress
    ##
    labels: {}

    ## Hostnames.
    ## Must be provided if Ingress is enable.
    ##
    # hosts:
    #   - grafana.domain.com
    hosts:
      - grafana-lasdpc.icmc.usp.br

    ## Path for grafana ingress
    path: /

    ## TLS configuration for grafana Ingress
    ## Secret must be manually created in the namespace
    ##
    tls:
    - secretName: grafana-tls
      hosts:
      - grafana-lasdpc.icmc.usp.br

  sidecar:
    dashboards:
      enabled: true
      label: grafana_dashboard
      labelValue: "1"
      # Allow discovery in all namespaces for dashboards
      searchNamespace: ALL

      ## Annotations for Grafana dashboard configmaps
      ##
      annotations: {}
      multicluster:
        global:
          enabled: false
        etcd:
          enabled: false
      provider:
        allowUiUpdates: false
    datasources:
      enabled: true
      defaultDatasourceEnabled: true
      isDefaultDatasource: true

      uid: prometheus

      ## URL of prometheus datasource
      ##
      # url: http://prometheus-stack-prometheus:9090/

      ## Prometheus request timeout in seconds
      # timeout: 30

      # If not defined, will use prometheus.prometheusSpec.scrapeInterval or its default
      # defaultDatasourceScrapeInterval: 15s

      ## Annotations for Grafana datasource configmaps
      ##
      annotations: {}

      ## Set method for HTTP to send query to datasource
      httpMethod: POST

      ## Create datasource for each Pod of Prometheus StatefulSet;
      ## this uses headless service `prometheus-operated` which is
      ## created by Prometheus Operator
      ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/0fee93e12dc7c2ea1218f19ae25ec6b893460590/pkg/prometheus/statefulset.go#L255-L286
      createPrometheusReplicasDatasources: false
      label: grafana_datasource
      labelValue: "1"

      ## Field with internal link pointing to existing data source in Grafana.
      ## Can be provisioned via additionalDataSources
      exemplarTraceIdDestinations: {}
        # datasourceUid: Jaeger
        # traceIdLabelName: trace_id
      alertmanager:
        enabled: true
        uid: alertmanager
        handleGrafanaManagedAlerts: false
        implementation: prometheus

  extraConfigmapMounts: []
  # - name: certs-configmap
  #   mountPath: /etc/grafana/ssl/
  #   configMap: certs-configmap
  #   readOnly: true

  deleteDatasources: []
  # - name: example-datasource
  #   orgId: 1

  ## Configure additional grafana datasources (passed through tpl)
  ## ref: http://docs.grafana.org/administration/provisioning/#datasources
  additionalDataSources:
    - name: Tempo
      type: tempo
      isDefault: false
      editable: true
      readOnly: false
      access: proxy
      url: http://tempo.istio-system.svc.cluster.local:3100
    - name: Loki
      type: loki
      isDefault: false
      editable: true
      readOnly: false
      access: proxy
      url: http://loki.monitoring.svc.cluster.local:3100
      version: 1
    - name: Node Graph API
      type: hamedkarbasi93-nodegraphapi-datasource
      isDefault: false
      access: proxy
      url: http://nodegraph-generator.monitoring.svc.cluster.local

  ## Passed to grafana subchart and used by servicemonitor below
  ##
  service:
    portName: http-web

  serviceMonitor:
    # If true, a ServiceMonitor CRD is created for a prometheus operator
    # https://github.com/coreos/prometheus-operator
    #
    enabled: true

    # Path to use for scraping metrics. Might be different if server.root_url is set
    # in grafana.ini
    path: "/metrics"

    #  namespace: monitoring  (defaults to use the namespace this chart is deployed to)

    # labels for the ServiceMonitor
    labels: {}

    # Scrape interval. If not set, the Prometheus default scrape interval is used.
    #
    interval: ""
    scheme: http
    tlsConfig: {}
    scrapeTimeout: 30s

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

## Flag to disable all the kubernetes component scrapers
##
kubernetesServiceMonitors:
  enabled: true

## Component scraping the kube api server
##
kubeApiServer:
  enabled: true
  tlsConfig:
    serverName: kubernetes
    insecureSkipVerify: false
  serviceMonitor:
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""

    ## SampleLimit defines per-scrape limit on number of scraped samples that will be accepted.
    ##
    sampleLimit: 0

    ## TargetLimit defines a limit on the number of scraped targets that will be accepted.
    ##
    targetLimit: 0

    ## Per-scrape limit on number of labels that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelLimit: 0

    ## Per-scrape limit on length of labels name that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelNameLengthLimit: 0

    ## Per-scrape limit on length of labels value that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelValueLengthLimit: 0

    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""

    jobLabel: component
    selector:
      matchLabels:
        component: apiserver
        provider: kubernetes

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings:
      # Drop excessively noisy apiserver buckets.
      - action: drop
        regex: apiserver_request_duration_seconds_bucket;(0.15|0.2|0.3|0.35|0.4|0.45|0.6|0.7|0.8|0.9|1.25|1.5|1.75|2|3|3.5|4|4.5|6|7|8|9|15|25|40|50)
        sourceLabels:
          - __name__
          - le
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels:
    #     - __meta_kubernetes_namespace
    #     - __meta_kubernetes_service_name
    #     - __meta_kubernetes_endpoint_port_name
    #   action: keep
    #   regex: default;kubernetes;https
    # - targetLabel: __address__
    #   replacement: kubernetes.default.svc:443

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar

## Component scraping the kubelet and kubelet-hosted cAdvisor
##
kubelet:
  enabled: true
  namespace: kube-system

  serviceMonitor:
    ## Attach metadata to discovered targets. Requires Prometheus v2.45 for endpoints created by the operator.
    ##
    attachMetadata:
      node: false

    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""

    ## If true, Prometheus use (respect) labels provided by exporter.
    ##
    honorLabels: true

    ## If true, Prometheus ingests metrics with timestamp provided by exporter. If false, Prometheus ingests metrics with timestamp of scrape.
    ##
    honorTimestamps: true

    ## SampleLimit defines per-scrape limit on number of scraped samples that will be accepted.
    ##
    sampleLimit: 0

    ## TargetLimit defines a limit on the number of scraped targets that will be accepted.
    ##
    targetLimit: 0

    ## Per-scrape limit on number of labels that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelLimit: 0

    ## Per-scrape limit on length of labels name that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelNameLengthLimit: 0

    ## Per-scrape limit on length of labels value that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelValueLengthLimit: 0

    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""

    ## Enable scraping the kubelet over https. For requirements to enable this see
    ## https://github.com/prometheus-operator/prometheus-operator/issues/926
    ##
    https: true

    ## Enable scraping /metrics/cadvisor from kubelet's service
    ##
    cAdvisor: true

    ## Enable scraping /metrics/probes from kubelet's service
    ##
    probes: true

    ## Enable scraping /metrics/resource from kubelet's service
    ## This is disabled by default because container metrics are already exposed by cAdvisor
    ##
    resource: false
    # From kubernetes 1.18, /metrics/resource/v1alpha1 renamed to /metrics/resource
    resourcePath: "/metrics/resource/v1alpha1"

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    cAdvisorMetricRelabelings:
      # Drop less useful container CPU metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: 'container_cpu_(cfs_throttled_seconds_total|load_average_10s|system_seconds_total|user_seconds_total)'
      # Drop less useful container / always zero filesystem metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: 'container_fs_(io_current|io_time_seconds_total|io_time_weighted_seconds_total|reads_merged_total|sector_reads_total|sector_writes_total|writes_merged_total)'
      # Drop less useful / always zero container memory metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: 'container_memory_(mapped_file|swap)'
      # Drop less useful container process metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: 'container_(file_descriptors|tasks_state|threads_max)'
      # Drop container spec metrics that overlap with kube-state-metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: 'container_spec.*'
      # Drop cgroup metrics with no pod.
      - sourceLabels: [id, pod]
        action: drop
        regex: '.+;'
    # - sourceLabels: [__name__, image]
    #   separator: ;
    #   regex: container_([a-z_]+);
    #   replacement: $1
    #   action: drop
    # - sourceLabels: [__name__]
    #   separator: ;
    #   regex: container_(network_tcp_usage_total|network_udp_usage_total|tasks_state|cpu_load_average_10s)
    #   replacement: $1
    #   action: drop

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    probesMetricRelabelings: []
    # - sourceLabels: [__name__, image]
    #   separator: ;
    #   regex: container_([a-z_]+);
    #   replacement: $1
    #   action: drop
    # - sourceLabels: [__name__]
    #   separator: ;
    #   regex: container_(network_tcp_usage_total|network_udp_usage_total|tasks_state|cpu_load_average_10s)
    #   replacement: $1
    #   action: drop

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    ## metrics_path is required to match upstream rules and charts
    cAdvisorRelabelings:
      - action: replace
        sourceLabels: [__metrics_path__]
        targetLabel: metrics_path
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    probesRelabelings:
      - action: replace
        sourceLabels: [__metrics_path__]
        targetLabel: metrics_path
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    resourceRelabelings:
      - action: replace
        sourceLabels: [__metrics_path__]
        targetLabel: metrics_path
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
    # - sourceLabels: [__name__, image]
    #   separator: ;
    #   regex: container_([a-z_]+);
    #   replacement: $1
    #   action: drop
    # - sourceLabels: [__name__]
    #   separator: ;
    #   regex: container_(network_tcp_usage_total|network_udp_usage_total|tasks_state|cpu_load_average_10s)
    #   replacement: $1
    #   action: drop

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    ## metrics_path is required to match upstream rules and charts
    relabelings:
      - action: replace
        sourceLabels: [__metrics_path__]
        targetLabel: metrics_path
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar

## Component scraping the kube controller manager
##
kubeControllerManager:
  enabled: true

  ## If your kube controller manager is not deployed as a pod, specify IPs it can be found on
  ##
  endpoints: []
  # - 10.141.4.22
  # - 10.141.4.23
  # - 10.141.4.24

  ## If using kubeControllerManager.endpoints only the port and targetPort are used
  ##
  service:
    enabled: true
    ## If null or unset, the value is determined dynamically based on target Kubernetes version due to change
    ## of default port in Kubernetes 1.22.
    ##
    port: null
    targetPort: null
    # selector:
    #   component: kube-controller-manager

  serviceMonitor:
    enabled: true
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""

    ## SampleLimit defines per-scrape limit on number of scraped samples that will be accepted.
    ##
    sampleLimit: 0

    ## TargetLimit defines a limit on the number of scraped targets that will be accepted.
    ##
    targetLimit: 0

    ## Per-scrape limit on number of labels that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelLimit: 0

    ## Per-scrape limit on length of labels name that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelNameLengthLimit: 0

    ## Per-scrape limit on length of labels value that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelValueLengthLimit: 0

    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""

    ## Enable scraping kube-controller-manager over https.
    ## Requires proper certs (not self-signed) and delegated authentication/authorization checks.
    ## If null or unset, the value is determined dynamically based on target Kubernetes version.
    ##
    https: null

    # Skip TLS certificate validation when scraping
    insecureSkipVerify: null

    # Name of the server to use when validating TLS certificate
    serverName: null

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar

## Component scraping coreDns. Use either this or kubeDns
##
coreDns:
  enabled: true
  service:
    port: 9153
    targetPort: 9153
    # selector:
    #   k8s-app: kube-dns
  serviceMonitor:
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""

    ## SampleLimit defines per-scrape limit on number of scraped samples that will be accepted.
    ##
    sampleLimit: 0

    ## TargetLimit defines a limit on the number of scraped targets that will be accepted.
    ##
    targetLimit: 0

    ## Per-scrape limit on number of labels that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelLimit: 0

    ## Per-scrape limit on length of labels name that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelNameLengthLimit: 0

    ## Per-scrape limit on length of labels value that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelValueLengthLimit: 0

    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar

## Component scraping kubeDns. Use either this or coreDns
##
kubeDns:
  enabled: false
  service:
    dnsmasq:
      port: 10054
      targetPort: 10054
    skydns:
      port: 10055
      targetPort: 10055
    # selector:
    #   k8s-app: kube-dns
  serviceMonitor:
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""

    ## SampleLimit defines per-scrape limit on number of scraped samples that will be accepted.
    ##
    sampleLimit: 0

    ## TargetLimit defines a limit on the number of scraped targets that will be accepted.
    ##
    targetLimit: 0

    ## Per-scrape limit on number of labels that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelLimit: 0

    ## Per-scrape limit on length of labels name that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelNameLengthLimit: 0

    ## Per-scrape limit on length of labels value that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelValueLengthLimit: 0

    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    dnsmasqMetricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    dnsmasqRelabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar

## Component scraping etcd
##
kubeEtcd:
  enabled: true

  ## If your etcd is not deployed as a pod, specify IPs it can be found on
  ##
  endpoints: []
  # - 10.141.4.22
  # - 10.141.4.23
  # - 10.141.4.24

  ## Etcd service. If using kubeEtcd.endpoints only the port and targetPort are used
  ##
  service:
    enabled: true
    port: 2381
    targetPort: 2381
    # selector:
    #   component: etcd

  ## Configure secure access to the etcd cluster by loading a secret into prometheus and
  ## specifying security configuration below. For example, with a secret named etcd-client-cert
  ##
  ## serviceMonitor:
  ##   scheme: https
  ##   insecureSkipVerify: false
  ##   serverName: localhost
  ##   caFile: /etc/prometheus/secrets/etcd-client-cert/etcd-ca
  ##   certFile: /etc/prometheus/secrets/etcd-client-cert/etcd-client
  ##   keyFile: /etc/prometheus/secrets/etcd-client-cert/etcd-client-key
  ##
  serviceMonitor:
    enabled: true
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""

    ## SampleLimit defines per-scrape limit on number of scraped samples that will be accepted.
    ##
    sampleLimit: 0

    ## TargetLimit defines a limit on the number of scraped targets that will be accepted.
    ##
    targetLimit: 0

    ## Per-scrape limit on number of labels that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelLimit: 0

    ## Per-scrape limit on length of labels name that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelNameLengthLimit: 0

    ## Per-scrape limit on length of labels value that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelValueLengthLimit: 0

    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""
    scheme: http
    insecureSkipVerify: false
    serverName: ""
    caFile: ""
    certFile: ""
    keyFile: ""

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar

## Component scraping kube scheduler
##
kubeScheduler:
  enabled: true

  ## If your kube scheduler is not deployed as a pod, specify IPs it can be found on
  ##
  endpoints: []
  # - 10.141.4.22
  # - 10.141.4.23
  # - 10.141.4.24

  ## If using kubeScheduler.endpoints only the port and targetPort are used
  ##
  service:
    enabled: true
    ## If null or unset, the value is determined dynamically based on target Kubernetes version due to change
    ## of default port in Kubernetes 1.23.
    ##
    port: null
    targetPort: null
    # selector:
    #   component: kube-scheduler

  serviceMonitor:
    enabled: true
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""

    ## SampleLimit defines per-scrape limit on number of scraped samples that will be accepted.
    ##
    sampleLimit: 0

    ## TargetLimit defines a limit on the number of scraped targets that will be accepted.
    ##
    targetLimit: 0

    ## Per-scrape limit on number of labels that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelLimit: 0

    ## Per-scrape limit on length of labels name that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelNameLengthLimit: 0

    ## Per-scrape limit on length of labels value that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelValueLengthLimit: 0

    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""
    ## Enable scraping kube-scheduler over https.
    ## Requires proper certs (not self-signed) and delegated authentication/authorization checks.
    ## If null or unset, the value is determined dynamically based on target Kubernetes version.
    ##
    https: null

    ## Skip TLS certificate validation when scraping
    insecureSkipVerify: null

    ## Name of the server to use when validating TLS certificate
    serverName: null

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar

## Component scraping kube proxy
##
kubeProxy:
  enabled: true

  ## If your kube proxy is not deployed as a pod, specify IPs it can be found on
  ##
  endpoints: []
  # - 10.141.4.22
  # - 10.141.4.23
  # - 10.141.4.24

  service:
    enabled: true
    port: 10249
    targetPort: 10249
    # selector:
    #   k8s-app: kube-proxy

  serviceMonitor:
    enabled: true
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""

    ## SampleLimit defines per-scrape limit on number of scraped samples that will be accepted.
    ##
    sampleLimit: 0

    ## TargetLimit defines a limit on the number of scraped targets that will be accepted.
    ##
    targetLimit: 0

    ## Per-scrape limit on number of labels that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelLimit: 0

    ## Per-scrape limit on length of labels name that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelNameLengthLimit: 0

    ## Per-scrape limit on length of labels value that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelValueLengthLimit: 0

    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""

    ## Enable scraping kube-proxy over https.
    ## Requires proper certs (not self-signed) and delegated authentication/authorization checks
    ##
    https: false

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar

## Component scraping kube state metrics
##
kubeStateMetrics:
  enabled: true

## Configuration for kube-state-metrics subchart
##
kube-state-metrics:
  namespaceOverride: ""
  rbac:
    create: true
  releaseLabel: true
  prometheus:
    monitor:
      enabled: true

      ## Scrape interval. If not set, the Prometheus default scrape interval is used.
      ##
      interval: ""

      ## SampleLimit defines per-scrape limit on number of scraped samples that will be accepted.
      ##
      sampleLimit: 0

      ## TargetLimit defines a limit on the number of scraped targets that will be accepted.
      ##
      targetLimit: 0

      ## Per-scrape limit on number of labels that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
      ##
      labelLimit: 0

      ## Per-scrape limit on length of labels name that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
      ##
      labelNameLengthLimit: 0

      ## Per-scrape limit on length of labels value that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
      ##
      labelValueLengthLimit: 0

      ## Scrape Timeout. If not set, the Prometheus default scrape timeout is used.
      ##
      scrapeTimeout: ""

      ## proxyUrl: URL of a proxy that should be used for scraping.
      ##
      proxyUrl: ""

      # Keep labels from scraped data, overriding server-side labels
      ##
      honorLabels: true

      ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
      ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
      ##
      metricRelabelings: []
      # - action: keep
      #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
      #   sourceLabels: [__name__]

      ## RelabelConfigs to apply to samples before scraping
      ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
      ##
      relabelings: []
      # - sourceLabels: [__meta_kubernetes_pod_node_name]
      #   separator: ;
      #   regex: ^(.*)$
      #   targetLabel: nodename
      #   replacement: $1
      #   action: replace

  selfMonitor:
    enabled: false

## Deploy node exporter as a daemonset to all nodes
##
nodeExporter:
  enabled: true
  operatingSystems:
    linux:
      enabled: true
    darwin:
      enabled: true

## Configuration for prometheus-node-exporter subchart
##
prometheus-node-exporter:
  namespaceOverride: ""
  podLabels:
    ## Add the 'node-exporter' label to be used by serviceMonitor to match standard common usage in rules and grafana dashboards
    ##
    jobLabel: node-exporter
  releaseLabel: true
  extraArgs:
    - --collector.filesystem.mount-points-exclude=^/(dev|proc|sys|var/lib/docker/.+|var/lib/kubelet/.+)($|/)
    - --collector.filesystem.fs-types-exclude=^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$
  service:
    portName: http-metrics
  prometheus:
    monitor:
      enabled: true

      jobLabel: jobLabel

      ## Scrape interval. If not set, the Prometheus default scrape interval is used.
      ##
      interval: ""

      ## SampleLimit defines per-scrape limit on number of scraped samples that will be accepted.
      ##
      sampleLimit: 0

      ## TargetLimit defines a limit on the number of scraped targets that will be accepted.
      ##
      targetLimit: 0

      ## Per-scrape limit on number of labels that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
      ##
      labelLimit: 0

      ## Per-scrape limit on length of labels name that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
      ##
      labelNameLengthLimit: 0

      ## Per-scrape limit on length of labels value that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
      ##
      labelValueLengthLimit: 0

      ## How long until a scrape request times out. If not set, the Prometheus default scape timeout is used.
      ##
      scrapeTimeout: ""

      ## proxyUrl: URL of a proxy that should be used for scraping.
      ##
      proxyUrl: ""

      ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
      ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
      ##
      metricRelabelings: []
      # - sourceLabels: [__name__]
      #   separator: ;
      #   regex: ^node_mountstats_nfs_(event|operations|transport)_.+
      #   replacement: $1
      #   action: drop

      ## RelabelConfigs to apply to samples before scraping
      ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
      ##
      relabelings: []
      # - sourceLabels: [__meta_kubernetes_pod_node_name]
      #   separator: ;
      #   regex: ^(.*)$
      #   targetLabel: nodename
      #   replacement: $1
      #   action: replace
  rbac:
    ## If true, create PSPs for node-exporter
    ##
    pspEnabled: false

## Manages Prometheus and Alertmanager components
##
prometheusOperator:
  enabled: true

  ## Number of old replicasets to retain ##
  ## The default value is 10, 0 will garbage-collect old replicasets ##
  revisionHistoryLimit: 10

  ## Prometheus-Operator v0.39.0 and later support TLS natively.
  ##
  tls:
    enabled: false
    # Value must match version names from https://golang.org/pkg/crypto/tls/#pkg-constants
    tlsMinVersion: VersionTLS13
    # The default webhook port is 10250 in order to work out-of-the-box in GKE private clusters and avoid adding firewall rules.
    internalPort: 10250

  ## Admission webhook support for PrometheusRules resources added in Prometheus Operator 0.30 can be enabled to prevent incorrectly formatted
  ## rules from making their way into prometheus and potentially preventing the container from starting
  admissionWebhooks:
    ## Valid values: Fail, Ignore, IgnoreOnInstallOnly
    ## IgnoreOnInstallOnly - If Release.IsInstall returns "true", set "Ignore" otherwise "Fail"
    failurePolicy: ""
    ## The default timeoutSeconds is 10 and the maximum value is 30.
    timeoutSeconds: 10
    enabled: false
    ## A PEM encoded CA bundle which will be used to validate the webhook's server certificate.
    ## If unspecified, system trust roots on the apiserver are used.
    caBundle: ""
    ## If enabled, generate a self-signed certificate, then patch the webhook configurations with the generated data.
    ## On chart upgrades (or if the secret exists) the cert will not be re-generated. You can use this to provide your own
    ## certs ahead of time if you wish.
    ##
    annotations: {}
    #   argocd.argoproj.io/hook: PreSync
    #   argocd.argoproj.io/hook-delete-policy: HookSucceeded
    patch:
      enabled: true
      image:
        registry: registry.k8s.io
        repository: ingress-nginx/kube-webhook-certgen
        tag: v20221220-controller-v1.5.1-58-g787ea74b6
        sha: ""
        pullPolicy: IfNotPresent
      resources: {}
      ## Provide a priority class name to the webhook patching job
      ##
      priorityClassName: ""
      annotations: {}
      #   argocd.argoproj.io/hook: PreSync
      #   argocd.argoproj.io/hook-delete-policy: HookSucceeded
      podAnnotations: {}
      nodeSelector: {}
      affinity: {}
      tolerations: []

      ## SecurityContext holds pod-level security attributes and common container settings.
      ## This defaults to non root user with uid 2000 and gid 2000. *v1.PodSecurityContext  false
      ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
      ##
      securityContext:
        runAsGroup: 2000
        runAsNonRoot: true
        runAsUser: 2000
        seccompProfile:
          type: RuntimeDefault

    # Security context for create job container
    createSecretJob:
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
          - ALL

      # Security context for patch job container
    patchWebhookJob:
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
          - ALL

    # Use certmanager to generate webhook certs
    certManager:
      enabled: false
      # self-signed root certificate
      rootCert:
        duration: ""  # default to be 5y
      admissionCert:
        duration: ""  # default to be 1y
      # issuerRef:
      #   name: "issuer"
      #   kind: "ClusterIssuer"

  ## Namespaces to scope the interaction of the Prometheus Operator and the apiserver (allow list).
  ## This is mutually exclusive with denyNamespaces. Setting this to an empty object will disable the configuration
  ##
  namespaces: {}
    # releaseNamespace: true
    # additional:
    # - kube-system

  ## Namespaces not to scope the interaction of the Prometheus Operator (deny list).
  ##
  denyNamespaces: []

  ## Filter namespaces to look for prometheus-operator custom resources
  ##
  alertmanagerInstanceNamespaces: []
  alertmanagerConfigNamespaces: []
  prometheusInstanceNamespaces: []
  thanosRulerInstanceNamespaces: []

  ## The clusterDomain value will be added to the cluster.peer option of the alertmanager.
  ## Without this specified option cluster.peer will have value alertmanager-monitoring-alertmanager-0.alertmanager-operated:9094 (default value)
  ## With this specified option cluster.peer will have value alertmanager-monitoring-alertmanager-0.alertmanager-operated.namespace.svc.cluster-domain:9094
  ##
  # clusterDomain: "cluster.local"

  networkPolicy:
    ## Enable creation of NetworkPolicy resources.
    ##
    enabled: false

    ## Flavor of the network policy to use.
    #  Can be:
    #  * kubernetes for networking.k8s.io/v1/NetworkPolicy
    #  * cilium     for cilium.io/v2/CiliumNetworkPolicy
    flavor: kubernetes

    # cilium:
    #   egress:

    ## match labels used in selector
    # matchLabels: {}

  ## Service account for Prometheus Operator to use.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
  ##
  serviceAccount:
    create: true
    name: ""

  ## Configuration for Prometheus operator service
  ##
  service:
    annotations: {}
    labels: {}
    clusterIP: ""

  ## Port to expose on each node
  ## Only used if service.type is 'NodePort'
  ##
    nodePort: 30080

    nodePortTls: 30443

  ## Additional ports to open for Prometheus operator service
  ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#multi-port-services
  ##
    additionalPorts: []

  ## Loadbalancer IP
  ## Only use if service.type is "LoadBalancer"
  ##
    loadBalancerIP: ""
    loadBalancerSourceRanges: []

    ## Denotes if this Service desires to route external traffic to node-local or cluster-wide endpoints
    ##
    externalTrafficPolicy: Cluster

  ## Service type
  ## NodePort, ClusterIP, LoadBalancer
  ##
    type: ClusterIP

    ## List of IP addresses at which the Prometheus server service is available
    ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
    ##
    externalIPs: []

  # ## Labels to add to the operator deployment
  # ##
  labels: {}

  ## Annotations to add to the operator deployment
  ##
  annotations: {}

  ## Labels to add to the operator pod
  ##
  podLabels: {}

  ## Annotations to add to the operator pod
  ##
  podAnnotations: {}

  ## Assign a PriorityClassName to pods if set
  # priorityClassName: ""

  ## Define Log Format
  # Use logfmt (default) or json logging
  # logFormat: logfmt

  ## Decrease log verbosity to errors only
  # logLevel: error

  ## If true, the operator will create and maintain a service for scraping kubelets
  ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/helm/prometheus-operator/README.md
  ##
  kubeletService:
    enabled: true
    namespace: kube-system
    ## Use '{{ template "kube-prometheus-stack.fullname" . }}-kubelet' by default
    name: ""

  ## Create a servicemonitor for the operator
  ##
  serviceMonitor:
    ## Labels for ServiceMonitor
    additionalLabels: {}

    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""

    ## SampleLimit defines per-scrape limit on number of scraped samples that will be accepted.
    ##
    sampleLimit: 0

    ## TargetLimit defines a limit on the number of scraped targets that will be accepted.
    ##
    targetLimit: 0

    ## Per-scrape limit on number of labels that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelLimit: 0

    ## Per-scrape limit on length of labels name that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelNameLengthLimit: 0

    ## Per-scrape limit on length of labels value that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelValueLengthLimit: 0

    ## Scrape timeout. If not set, the Prometheus default scrape timeout is used.
    scrapeTimeout: ""
    selfMonitor: true

    ## Metric relabel configs to apply to samples before ingestion.
    ##
    metricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    #   relabel configs to apply to samples before ingestion.
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

  ## Resource limits & requests
  ##
  resources: {}
  # limits:
  #   cpu: 200m
  #   memory: 200Mi
  # requests:
  #   cpu: 100m
  #   memory: 100Mi

  # Required for use in managed kubernetes clusters (such as AWS EKS) with custom CNI (such as calico),
  # because control-plane managed by AWS cannot communicate with pods' IP CIDR and admission webhooks are not working
  ##
  hostNetwork: false

  ## Define which Nodes the Pods are scheduled on.
  ## ref: https://kubernetes.io/docs/user-guide/node-selection/
  ##
  nodeSelector: {}

  ## Tolerations for use with node taints
  ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  # - key: "key"
  #   operator: "Equal"
  #   value: "value"
  #   effect: "NoSchedule"

  ## Assign custom affinity rules to the prometheus operator
  ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  ##
  affinity: {}
    # nodeAffinity:
    #   requiredDuringSchedulingIgnoredDuringExecution:
    #     nodeSelectorTerms:
    #     - matchExpressions:
    #       - key: kubernetes.io/e2e-az-name
    #         operator: In
    #         values:
    #         - e2e-az1
    #         - e2e-az2
  dnsConfig: {}
    # nameservers:
    #   - 1.2.3.4
    # searches:
    #   - ns1.svc.cluster-domain.example
    #   - my.dns.search.suffix
    # options:
    #   - name: ndots
    #     value: "2"
  #   - name: edns0
  securityContext:
    fsGroup: 65534
    runAsGroup: 65534
    runAsNonRoot: true
    runAsUser: 65534
    seccompProfile:
      type: RuntimeDefault

  ## Container-specific security context configuration
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
  ##
  containerSecurityContext:
    allowPrivilegeEscalation: false
    readOnlyRootFilesystem: true
    capabilities:
      drop:
      - ALL

  # Enable vertical pod autoscaler support for prometheus-operator
  verticalPodAutoscaler:
    enabled: false

    # Recommender responsible for generating recommendation for the object.
    # List should be empty (then the default recommender will generate the recommendation)
    # or contain exactly one recommender.
    # recommenders:
    # - name: custom-recommender-performance

    # List of resources that the vertical pod autoscaler can control. Defaults to cpu and memory
    controlledResources: []
    # Specifies which resource values should be controlled: RequestsOnly or RequestsAndLimits.
    # controlledValues: RequestsAndLimits

    # Define the max allowed resources for the pod
    maxAllowed: {}
    # cpu: 200m
    # memory: 100Mi
    # Define the min allowed resources for the pod
    minAllowed: {}
    # cpu: 200m
    # memory: 100Mi

    updatePolicy:
      # Specifies minimal number of replicas which need to be alive for VPA Updater to attempt pod eviction
      # minReplicas: 1
      # Specifies whether recommended updates are applied when a Pod is started and whether recommended updates
      # are applied during the life of a Pod. Possible values are "Off", "Initial", "Recreate", and "Auto".
      updateMode: Auto

  ## Prometheus-operator image
  ##
  image:
    registry: quay.io
    repository: prometheus-operator/prometheus-operator
    # if not set appVersion field from Chart.yaml is used
    tag: ""
    sha: ""
    pullPolicy: IfNotPresent

  ## Prometheus image to use for prometheuses managed by the operator
  ##
  # prometheusDefaultBaseImage: prometheus/prometheus

  ## Prometheus image registry to use for prometheuses managed by the operator
  ##
  # prometheusDefaultBaseImageRegistry: quay.io

  ## Alertmanager image to use for alertmanagers managed by the operator
  ##
  # alertmanagerDefaultBaseImage: prometheus/alertmanager

  ## Alertmanager image registry to use for alertmanagers managed by the operator
  ##
  # alertmanagerDefaultBaseImageRegistry: quay.io

  ## Prometheus-config-reloader
  ##
  prometheusConfigReloader:
    image:
      registry: quay.io
      repository: prometheus-operator/prometheus-config-reloader
      # if not set appVersion field from Chart.yaml is used
      tag: ""
      sha: ""

    # add prometheus config reloader liveness and readiness probe. Default: false
    enableProbe: false

    # resource config for prometheusConfigReloader
    resources: {}
      # requests:
      #   cpu: 200m
      #   memory: 50Mi
      # limits:
      #   cpu: 200m
      #   memory: 50Mi

  ## Thanos side-car image when configured
  ##
  thanosImage:
    registry: quay.io
    repository: thanos/thanos
    tag: v0.32.5
    sha: ""

  ## Set a Label Selector to filter watched prometheus and prometheusAgent
  ##
  prometheusInstanceSelector: ""

  ## Set a Label Selector to filter watched alertmanager
  ##
  alertmanagerInstanceSelector: ""

  ## Set a Label Selector to filter watched thanosRuler
  thanosRulerInstanceSelector: ""

  ## Set a Field Selector to filter watched secrets
  ##
  secretFieldSelector: "type!=kubernetes.io/dockercfg,type!=kubernetes.io/service-account-token,type!=helm.sh/release.v1"

## Deploy a Prometheus instance
##
prometheus:
  enabled: true

  ## Toggle prometheus into agent mode
  ## Note many of features described below (e.g. rules, query, alerting, remote read, thanos) will not work in agent mode.
  ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/designs/prometheus-agent.md
  ##
  agentMode: false

  ## Annotations for Prometheus
  ##
  annotations: {}

  ## Configure network policy for the prometheus
  networkPolicy:
    enabled: false

    ## Flavor of the network policy to use.
    #  Can be:
    #  * kubernetes for networking.k8s.io/v1/NetworkPolicy
    #  * cilium     for cilium.io/v2/CiliumNetworkPolicy
    flavor: kubernetes

    # cilium:
    #   endpointSelector:
    #   egress:
    #   ingress:

    # egress:
    # - {}
    # ingress:
    # - {}
    # podSelector:
    #   matchLabels:
    #     app: prometheus

  ## Service account for Prometheuses to use.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
  ##
  serviceAccount:
    create: true
    name: ""
    annotations: {}

  # Service for thanos service discovery on sidecar
  # Enable this can make Thanos Query can use
  thanosService:
    enabled: false
    annotations: {}
    labels: {}

    ## Denotes if this Service desires to route external traffic to node-local or cluster-wide endpoints
    ##
    externalTrafficPolicy: Cluster

    ## Service type
    ##
    type: ClusterIP

    ## gRPC port config
    portName: grpc
    port: 10901
    targetPort: "grpc"

    ## HTTP port config (for metrics)
    httpPortName: http
    httpPort: 10902
    targetHttpPort: "http"

    ## ClusterIP to assign
    # Default is to make this a headless service ("None")
    clusterIP: "None"

    ## Port to expose on each node, if service type is NodePort
    ##
    nodePort: 30901
    httpNodePort: 30902

  # ServiceMonitor to scrape Sidecar metrics
  # Needs thanosService to be enabled as well
  thanosServiceMonitor:
    enabled: false
    interval: ""

    ## Additional labels
    ##
    additionalLabels: {}

    ## scheme: HTTP scheme to use for scraping. Can be used with `tlsConfig` for example if using istio mTLS.
    scheme: ""

    ## tlsConfig: TLS configuration to use when scraping the endpoint. For example if using istio mTLS.
    ## Of type: https://github.com/coreos/prometheus-operator/blob/main/Documentation/api.md#tlsconfig
    tlsConfig: {}

    bearerTokenFile:

    ## Metric relabel configs to apply to samples before ingestion.
    metricRelabelings: []

    ## relabel configs to apply to samples before ingestion.
    relabelings: []

  # Service for external access to sidecar
  # Enabling this creates a service to expose thanos-sidecar outside the cluster.
  thanosServiceExternal:
    enabled: false
    annotations: {}
    labels: {}
    loadBalancerIP: ""
    loadBalancerSourceRanges: []

    ## gRPC port config
    portName: grpc
    port: 10901
    targetPort: "grpc"

    ## HTTP port config (for metrics)
    httpPortName: http
    httpPort: 10902
    targetHttpPort: "http"

    ## Denotes if this Service desires to route external traffic to node-local or cluster-wide endpoints
    ##
    externalTrafficPolicy: Cluster

    ## Service type
    ##
    type: LoadBalancer

    ## Port to expose on each node
    ##
    nodePort: 30901
    httpNodePort: 30902

  ## Configuration for Prometheus service
  ##
  service:
    annotations: {}
    labels: {}
    clusterIP: ""

    ## Port for Prometheus Service to listen on
    ##
    port: 9090

    ## To be used with a proxy extraContainer port
    targetPort: 9090

    ## List of IP addresses at which the Prometheus server service is available
    ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
    ##
    externalIPs: []

    ## Port to expose on each node
    ## Only used if service.type is 'NodePort'
    ##
    nodePort: 30090

    ## Loadbalancer IP
    ## Only use if service.type is "LoadBalancer"
    loadBalancerIP: ""
    loadBalancerSourceRanges: []

    ## Denotes if this Service desires to route external traffic to node-local or cluster-wide endpoints
    ##
    externalTrafficPolicy: Cluster

    ## Service type
    ##
    type: ClusterIP

    ## Additional ports to open for Prometheus service
    ##
    additionalPorts: []
    # additionalPorts:
    # - name: oauth-proxy
    #   port: 8081
    #   targetPort: 8081
    # - name: oauth-metrics
    #   port: 8082
    #   targetPort: 8082

    ## Consider that all endpoints are considered "ready" even if the Pods themselves are not
    ## Ref: https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/#ServiceSpec
    publishNotReadyAddresses: false

    sessionAffinity: ""

  ## Configuration for creating a separate Service for each statefulset Prometheus replica
  ##
  servicePerReplica:
    enabled: false
    annotations: {}

    ## Port for Prometheus Service per replica to listen on
    ##
    port: 9090

    ## To be used with a proxy extraContainer port
    targetPort: 9090

    ## Port to expose on each node
    ## Only used if servicePerReplica.type is 'NodePort'
    ##
    nodePort: 30091

    ## Loadbalancer source IP ranges
    ## Only used if servicePerReplica.type is "LoadBalancer"
    loadBalancerSourceRanges: []

    ## Denotes if this Service desires to route external traffic to node-local or cluster-wide endpoints
    ##
    externalTrafficPolicy: Cluster

    ## Service type
    ##
    type: ClusterIP

  ## Configure pod disruption budgets for Prometheus
  ## ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/#specifying-a-poddisruptionbudget
  ## This configuration is immutable once created and will require the PDB to be deleted to be changed
  ## https://github.com/kubernetes/kubernetes/issues/45398
  ##
  podDisruptionBudget:
    enabled: false
    minAvailable: 1
    maxUnavailable: ""

  # Ingress exposes thanos sidecar outside the cluster
  thanosIngress:
    enabled: false

    # For Kubernetes >= 1.18 you should specify the ingress-controller via the field ingressClassName
    # See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#specifying-the-class-of-an-ingress
    # ingressClassName: nginx

    annotations: {}
    labels: {}
    servicePort: 10901

    ## Port to expose on each node
    ## Only used if service.type is 'NodePort'
    ##
    nodePort: 30901

    ## Hosts must be provided if Ingress is enabled.
    ##
    hosts: []
      # - thanos-gateway.domain.com

    ## Paths to use for ingress rules
    ##
    paths: []
    # - /

    ## For Kubernetes >= 1.18 you should specify the pathType (determines how Ingress paths should be matched)
    ## See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#better-path-matching-with-path-types
    # pathType: ImplementationSpecific

    ## TLS configuration for Thanos Ingress
    ## Secret must be manually created in the namespace
    ##
    tls: []
    # - secretName: thanos-gateway-tls
    #   hosts:
    #   - thanos-gateway.domain.com
    #

  ## ExtraSecret can be used to store various data in an extra secret
  ## (use it for example to store hashed basic auth credentials)
  extraSecret:
    ## if not set, name will be auto generated
    # name: ""
    annotations: {}
    data: {}
  #   auth: |
  #     foo:$apr1$OFG3Xybp$ckL0FHDAkoXYIlH9.cysT0
  #     someoneelse:$apr1$DMZX2Z4q$6SbQIfyuLQd.xmo/P0m2c.

  ingress:
    enabled: false

    # For Kubernetes >= 1.18 you should specify the ingress-controller via the field ingressClassName
    # See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#specifying-the-class-of-an-ingress
    # ingressClassName: nginx

    annotations: {}
    labels: {}

    ## Redirect ingress to an additional defined port on the service
    # servicePort: 8081

    ## Hostnames.
    ## Must be provided if Ingress is enabled.
    ##
    # hosts:
    #   - prometheus.domain.com
    hosts: []

    ## Paths to use for ingress rules - one path should match the prometheusSpec.routePrefix
    ##
    paths: []
    # - /

    ## For Kubernetes >= 1.18 you should specify the pathType (determines how Ingress paths should be matched)
    ## See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#better-path-matching-with-path-types
    # pathType: ImplementationSpecific

    ## TLS configuration for Prometheus Ingress
    ## Secret must be manually created in the namespace
    ##
    tls: []
      # - secretName: prometheus-general-tls
      #   hosts:
      #     - prometheus.example.com

  ## Configuration for creating an Ingress that will map to each Prometheus replica service
  ## prometheus.servicePerReplica must be enabled
  ##
  ingressPerReplica:
    enabled: false

    # For Kubernetes >= 1.18 you should specify the ingress-controller via the field ingressClassName
    # See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#specifying-the-class-of-an-ingress
    # ingressClassName: nginx

    annotations: {}
    labels: {}

    ## Final form of the hostname for each per replica ingress is
    ## {{ ingressPerReplica.hostPrefix }}-{{ $replicaNumber }}.{{ ingressPerReplica.hostDomain }}
    ##
    ## Prefix for the per replica ingress that will have `-$replicaNumber`
    ## appended to the end
    hostPrefix: ""
    ## Domain that will be used for the per replica ingress
    hostDomain: ""

    ## Paths to use for ingress rules
    ##
    paths: []
    # - /

    ## For Kubernetes >= 1.18 you should specify the pathType (determines how Ingress paths should be matched)
    ## See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#better-path-matching-with-path-types
    # pathType: ImplementationSpecific

    ## Secret name containing the TLS certificate for Prometheus per replica ingress
    ## Secret must be manually created in the namespace
    tlsSecretName: ""

    ## Separated secret for each per replica Ingress. Can be used together with cert-manager
    ##
    tlsSecretPerReplica:
      enabled: false
      ## Final form of the secret for each per replica ingress is
      ## {{ tlsSecretPerReplica.prefix }}-{{ $replicaNumber }}
      ##
      prefix: "prometheus"

  ## Configure additional options for default pod security policy for Prometheus
  ## ref: https://kubernetes.io/docs/concepts/policy/pod-security-policy/
  podSecurityPolicy:
    allowedCapabilities: []
    allowedHostPaths: []
    volumes: []

  serviceMonitor:
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""
    selfMonitor: true

    ## Additional labels
    ##
    additionalLabels: {}

    ## SampleLimit defines per-scrape limit on number of scraped samples that will be accepted.
    ##
    sampleLimit: 0

    ## TargetLimit defines a limit on the number of scraped targets that will be accepted.
    ##
    targetLimit: 0

    ## Per-scrape limit on number of labels that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelLimit: 0

    ## Per-scrape limit on length of labels name that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelNameLengthLimit: 0

    ## Per-scrape limit on length of labels value that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelValueLengthLimit: 0

    ## scheme: HTTP scheme to use for scraping. Can be used with `tlsConfig` for example if using istio mTLS.
    scheme: ""

    ## tlsConfig: TLS configuration to use when scraping the endpoint. For example if using istio mTLS.
    ## Of type: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#tlsconfig
    tlsConfig: {}

    bearerTokenFile:

    ## Metric relabel configs to apply to samples before ingestion.
    ##
    metricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    #   relabel configs to apply to samples before ingestion.
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## Additional Endpoints
    ##
    additionalEndpoints: []
    # - port: oauth-metrics
    #   path: /metrics

  ## Settings affecting prometheusSpec
  ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#prometheusspec
  ##
  prometheusSpec:
    ## If true, pass --storage.tsdb.max-block-duration=2h to prometheus. This is already done if using Thanos
    ##
    disableCompaction: false
    ## APIServerConfig
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#apiserverconfig
    ##
    apiserverConfig: {}

    ## Allows setting additional arguments for the Prometheus container
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.Prometheus
    additionalArgs: []

    ## Interval between consecutive scrapes.
    ## Defaults to 30s.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/release-0.44/pkg/prometheus/promcfg.go#L180-L183
    ##
    scrapeInterval: ""

    ## Number of seconds to wait for target to respond before erroring
    ##
    scrapeTimeout: ""

    ## Interval between consecutive evaluations.
    ##
    evaluationInterval: ""

    ## ListenLocal makes the Prometheus server listen on loopback, so that it does not bind against the Pod IP.
    ##
    listenLocal: false

    ## EnableAdminAPI enables Prometheus the administrative HTTP API which includes functionality such as deleting time series.
    ## This is disabled by default.
    ## ref: https://prometheus.io/docs/prometheus/latest/querying/api/#tsdb-admin-apis
    ##
    enableAdminAPI: false

    ## Sets version of Prometheus overriding the Prometheus version as derived
    ## from the image tag. Useful in cases where the tag does not follow semver v2.
    version: ""

    ## WebTLSConfig defines the TLS parameters for HTTPS
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#webtlsconfig
    web: {}

    ## Exemplars related settings that are runtime reloadable.
    ## It requires to enable the exemplar storage feature to be effective.
    exemplars: ""
      ## Maximum number of exemplars stored in memory for all series.
      ## If not set, Prometheus uses its default value.
      ## A value of zero or less than zero disables the storage.
      # maxSize: 100000

    # EnableFeatures API enables access to Prometheus disabled features.
    # ref: https://prometheus.io/docs/prometheus/latest/disabled_features/
    enableFeatures: []
    # - exemplar-storage

    ## Image of Prometheus.
    ##
    image:
      registry: quay.io
      repository: prometheus/prometheus
      tag: v2.48.0
      sha: ""

    ## Tolerations for use with node taints
    ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
    ##
    tolerations: []
    #  - key: "key"
    #    operator: "Equal"
    #    value: "value"
    #    effect: "NoSchedule"

    ## If specified, the pod's topology spread constraints.
    ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
    ##
    topologySpreadConstraints: []
    # - maxSkew: 1
    #   topologyKey: topology.kubernetes.io/zone
    #   whenUnsatisfiable: DoNotSchedule
    #   labelSelector:
    #     matchLabels:
    #       app: prometheus

    ## Alertmanagers to which alerts will be sent
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#alertmanagerendpoints
    ##
    ## Default configuration will connect to the alertmanager deployed as part of this release
    ##
    alertingEndpoints: []
    # - name: ""
    #   namespace: ""
    #   port: http
    #   scheme: http
    #   pathPrefix: ""
    #   tlsConfig: {}
    #   bearerTokenFile: ""
    #   apiVersion: v2

    ## External labels to add to any time series or alerts when communicating with external systems
    ##
    externalLabels: {}

    ## enable --web.enable-remote-write-receiver flag on prometheus-server
    ##
    enableRemoteWriteReceiver: false

    ## Name of the external label used to denote replica name
    ##
    replicaExternalLabelName: ""

    ## If true, the Operator won't add the external label used to denote replica name
    ##
    replicaExternalLabelNameClear: false

    ## Name of the external label used to denote Prometheus instance name
    ##
    prometheusExternalLabelName: ""

    ## If true, the Operator won't add the external label used to denote Prometheus instance name
    ##
    prometheusExternalLabelNameClear: false

    ## External URL at which Prometheus will be reachable.
    ##
    externalUrl: ""

    ## Define which Nodes the Pods are scheduled on.
    ## ref: https://kubernetes.io/docs/user-guide/node-selection/
    ##
    nodeSelector: {}

    ## Secrets is a list of Secrets in the same namespace as the Prometheus object, which shall be mounted into the Prometheus Pods.
    ## The Secrets are mounted into /etc/prometheus/secrets/. Secrets changes after initial creation of a Prometheus object are not
    ## reflected in the running Pods. To change the secrets mounted into the Prometheus Pods, the object must be deleted and recreated
    ## with the new list of secrets.
    ##
    secrets: []

    ## ConfigMaps is a list of ConfigMaps in the same namespace as the Prometheus object, which shall be mounted into the Prometheus Pods.
    ## The ConfigMaps are mounted into /etc/prometheus/configmaps/.
    ##
    configMaps: []

    ## QuerySpec defines the query command line flags when starting Prometheus.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#queryspec
    ##
    query: {}

    ## If nil, select own namespace. Namespaces to be selected for PrometheusRules discovery.
    ruleNamespaceSelector: {}
    ## Example which selects PrometheusRules in namespaces with label "prometheus" set to "somelabel"
    # ruleNamespaceSelector:
    #   matchLabels:
    #     prometheus: somelabel

    ## If true, a nil or {} value for prometheus.prometheusSpec.ruleSelector will cause the
    ## prometheus resource to be created with selectors based on values in the helm deployment,
    ## which will also match the PrometheusRule resources created
    ##
    ruleSelectorNilUsesHelmValues: true

    ## PrometheusRules to be selected for target discovery.
    ## If {}, select all PrometheusRules
    ##
    ruleSelector: {}
    ## Example which select all PrometheusRules resources
    ## with label "prometheus" with values any of "example-rules" or "example-rules-2"
    # ruleSelector:
    #   matchExpressions:
    #     - key: prometheus
    #       operator: In
    #       values:
    #         - example-rules
    #         - example-rules-2
    #
    ## Example which select all PrometheusRules resources with label "role" set to "example-rules"
    # ruleSelector:
    #   matchLabels:
    #     role: example-rules

    ## If true, a nil or {} value for prometheus.prometheusSpec.serviceMonitorSelector will cause the
    ## prometheus resource to be created with selectors based on values in the helm deployment,
    ## which will also match the servicemonitors created
    ##
    serviceMonitorSelectorNilUsesHelmValues: true

    ## ServiceMonitors to be selected for target discovery.
    ## If {}, select all ServiceMonitors
    ##
    serviceMonitorSelector: {}
    ## Example which selects ServiceMonitors with label "prometheus" set to "somelabel"
    # serviceMonitorSelector:
    #   matchLabels:
    #     prometheus: somelabel

    ## Namespaces to be selected for ServiceMonitor discovery.
    ##
    serviceMonitorNamespaceSelector: {}
    ## Example which selects ServiceMonitors in namespaces with label "prometheus" set to "somelabel"
    # serviceMonitorNamespaceSelector:
    #   matchLabels:
    #     prometheus: somelabel

    ## If true, a nil or {} value for prometheus.prometheusSpec.podMonitorSelector will cause the
    ## prometheus resource to be created with selectors based on values in the helm deployment,
    ## which will also match the podmonitors created
    ##
    podMonitorSelectorNilUsesHelmValues: true

    ## PodMonitors to be selected for target discovery.
    ## If {}, select all PodMonitors
    ##
    podMonitorSelector: {}
    ## Example which selects PodMonitors with label "prometheus" set to "somelabel"
    # podMonitorSelector:
    #   matchLabels:
    #     prometheus: somelabel

    ## If nil, select own namespace. Namespaces to be selected for PodMonitor discovery.
    podMonitorNamespaceSelector: {}
    ## Example which selects PodMonitor in namespaces with label "prometheus" set to "somelabel"
    # podMonitorNamespaceSelector:
    #   matchLabels:
    #     prometheus: somelabel

    ## If true, a nil or {} value for prometheus.prometheusSpec.probeSelector will cause the
    ## prometheus resource to be created with selectors based on values in the helm deployment,
    ## which will also match the probes created
    ##
    probeSelectorNilUsesHelmValues: true

    ## Probes to be selected for target discovery.
    ## If {}, select all Probes
    ##
    probeSelector: {}
    ## Example which selects Probes with label "prometheus" set to "somelabel"
    # probeSelector:
    #   matchLabels:
    #     prometheus: somelabel

    ## If nil, select own namespace. Namespaces to be selected for Probe discovery.
    probeNamespaceSelector: {}
    ## Example which selects Probe in namespaces with label "prometheus" set to "somelabel"
    # probeNamespaceSelector:
    #   matchLabels:
    #     prometheus: somelabel

    ## If true, a nil or {} value for prometheus.prometheusSpec.scrapeConfigSelector will cause the
    ## prometheus resource to be created with selectors based on values in the helm deployment,
    ## which will also match the scrapeConfigs created
    ##
    scrapeConfigSelectorNilUsesHelmValues: true

    ## scrapeConfigs to be selected for target discovery.
    ## If {}, select all scrapeConfigs
    ##
    scrapeConfigSelector: {}
    ## Example which selects scrapeConfigs with label "prometheus" set to "somelabel"
    # scrapeConfig:
    #   matchLabels:
    #     prometheus: somelabel

    ## If nil, select own namespace. Namespaces to be selected for scrapeConfig discovery.
    scrapeConfigNamespaceSelector: {}
    ## Example which selects scrapeConfig in namespaces with label "prometheus" set to "somelabel"
    # scrapeConfigNamespaceSelector:
    #   matchLabels:
    #     prometheus: somelabel

    ## How long to retain metrics
    ##
    retention: 10d

    ## Maximum size of metrics
    ##
    retentionSize: ""

    ## Allow out-of-order/out-of-bounds samples ingested into Prometheus for a specified duration
    ## See https://prometheus.io/docs/prometheus/latest/configuration/configuration/#tsdb
    tsdb:
      outOfOrderTimeWindow: 0s

    ## Enable compression of the write-ahead log using Snappy.
    ##
    walCompression: true

    ## If true, the Operator won't process any Prometheus configuration changes
    ##
    paused: false

    ## Number of replicas of each shard to deploy for a Prometheus deployment.
    ## Number of replicas multiplied by shards is the total number of Pods created.
    ##
    replicas: 2

    ## EXPERIMENTAL: Number of shards to distribute targets onto.
    ## Number of replicas multiplied by shards is the total number of Pods created.
    ## Note that scaling down shards will not reshard data onto remaining instances, it must be manually moved.
    ## Increasing shards will not reshard data either but it will continue to be available from the same instances.
    ## To query globally use Thanos sidecar and Thanos querier or remote write data to a central location.
    ## Sharding is done on the content of the `__address__` target meta-label.
    ##
    shards: 1

    ## Log level for Prometheus be configured in
    ##
    logLevel: info

    ## Log format for Prometheus be configured in
    ##
    logFormat: logfmt

    ## Prefix used to register routes, overriding externalUrl route.
    ## Useful for proxies that rewrite URLs.
    ##
    routePrefix: /

    ## Standard object's metadata. More info: https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md#metadata
    ## Metadata Labels and Annotations gets propagated to the prometheus pods.
    ##
    podMetadata: {}
    # labels:
    #   app: prometheus
    #   k8s-app: prometheus

    ## Pod anti-affinity can prevent the scheduler from placing Prometheus replicas on the same node.
    ## The default value "soft" means that the scheduler should *prefer* to not schedule two replica pods onto the same node but no guarantee is provided.
    ## The value "hard" means that the scheduler is *required* to not schedule two replica pods onto the same node.
    ## The value "" will disable pod anti-affinity so that no anti-affinity rules will be configured.
    podAntiAffinity: ""

    ## If anti-affinity is enabled sets the topologyKey to use for anti-affinity.
    ## This can be changed to, for example, failure-domain.beta.kubernetes.io/zone
    ##
    podAntiAffinityTopologyKey: kubernetes.io/hostname

    ## Assign custom affinity rules to the prometheus instance
    ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
    ##
    affinity: {}
    # nodeAffinity:
    #   requiredDuringSchedulingIgnoredDuringExecution:
    #     nodeSelectorTerms:
    #     - matchExpressions:
    #       - key: kubernetes.io/e2e-az-name
    #         operator: In
    #         values:
    #         - e2e-az1
    #         - e2e-az2

    ## The remote_read spec configuration for Prometheus.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#remotereadspec
    remoteRead: []
    # - url: http://remote1/read
    ## additionalRemoteRead is appended to remoteRead
    additionalRemoteRead: []

    ## The remote_write spec configuration for Prometheus.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#remotewritespec
    remoteWrite: []
    # - url: http://remote1/push
    ## additionalRemoteWrite is appended to remoteWrite
    additionalRemoteWrite: []

    ## Enable/Disable Grafana dashboards provisioning for prometheus remote write feature
    remoteWriteDashboards: false

    ## Resource limits & requests
    ##
    resources: {}
    # requests:
    #   memory: 400Mi

    ## Prometheus StorageSpec for persistent data
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/storage.md
    ##
    storageSpec:
    ## Using PersistentVolumeClaim
    ##
     volumeClaimTemplate:
       spec:
         storageClassName: gp2
         accessModes: ["ReadWriteOnce"]
         resources:
           requests:
             storage: 50Gi

    ## Using tmpfs volume
    ##
    #  emptyDir:
    #    medium: Memory

    # Additional volumes on the output StatefulSet definition.
    volumes: []

    # Additional VolumeMounts on the output StatefulSet definition.
    volumeMounts: []

    ## AdditionalScrapeConfigs allows specifying additional Prometheus scrape configurations. Scrape configurations
    ## are appended to the configurations generated by the Prometheus Operator. Job configurations must have the form
    ## as specified in the official Prometheus documentation:
    ## https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config. As scrape configs are
    ## appended, the user is responsible to make sure it is valid. Note that using this feature may expose the possibility
    ## to break upgrades of Prometheus. It is advised to review Prometheus release notes to ensure that no incompatible
    ## scrape configs are going to break Prometheus after the upgrade.
    ## AdditionalScrapeConfigs can be defined as a list or as a templated string.
    ##
    ## The scrape configuration example below will find master nodes, provided they have the name .*mst.*, relabel the
    ## port to 2379 and allow etcd scraping provided it is running on all Kubernetes master nodes
    ##
    additionalScrapeConfigs:

      - job_name: 'istiod'
        kubernetes_sd_configs:
          - role: endpoints
            namespaces:
              names:
                - istio-system
        relabel_configs:
          - source_labels: [__meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
            action: keep
            regex: istiod;http-monitoring
      - job_name: 'envoy-stats'
        metrics_path: /stats/prometheus
        kubernetes_sd_configs:
        - role: pod

        relabel_configs:
        - source_labels: [__meta_kubernetes_pod_container_port_name]
          action: keep
          regex: '.*-envoy-prom'


    # - job_name: kube-etcd
    #   kubernetes_sd_configs:
    #     - role: node
    #   scheme: https
    #   tls_config:
    #     ca_file:   /etc/prometheus/secrets/etcd-client-cert/etcd-ca
    #     cert_file: /etc/prometheus/secrets/etcd-client-cert/etcd-client
    #     key_file:  /etc/prometheus/secrets/etcd-client-cert/etcd-client-key
    #   relabel_configs:
    #   - action: labelmap
    #     regex: __meta_kubernetes_node_label_(.+)
    #   - source_labels: [__address__]
    #     action: replace
    #     targetLabel: __address__
    #     regex: ([^:;]+):(\d+)
    #   - source_labels: [__meta_kubernetes_node_name]
    #     action: keep
    #     regex: .*mst.*
    #   - source_labels: [__meta_kubernetes_node_name]
    #     action: replace
    #     targetLabel: node
    #     regex: (.*)
    #   metric_relabel_configs:
    #   - regex: (kubernetes_io_hostname|failure_domain_beta_kubernetes_io_region|beta_kubernetes_io_os|beta_kubernetes_io_arch|beta_kubernetes_io_instance_type|failure_domain_beta_kubernetes_io_zone)
    #     action: labeldrop
    #
    ## If scrape config contains a repetitive section, you may want to use a template.
    ## In the following example, you can see how to define `gce_sd_configs` for multiple zones
    # additionalScrapeConfigs: |
    #  - job_name: "node-exporter"
    #    gce_sd_configs:
    #    {{range $zone := .Values.gcp_zones}}
    #    - project: "project1"
    #      zone: "{{$zone}}"
    #      port: 9100
    #    {{end}}
    #    relabel_configs:
    #    ...


    ## If additional scrape configurations are already deployed in a single secret file you can use this section.
    ## Expected values are the secret name and key
    ## Cannot be used with additionalScrapeConfigs
    additionalScrapeConfigsSecret: {}
      # enabled: false
      # name:
      # key:

    ## additionalPrometheusSecretsAnnotations allows to add annotations to the kubernetes secret. This can be useful
    ## when deploying via spinnaker to disable versioning on the secret, strategy.spinnaker.io/versioned: 'false'
    additionalPrometheusSecretsAnnotations: {}

    ## AdditionalAlertManagerConfigs allows for manual configuration of alertmanager jobs in the form as specified
    ## in the official Prometheus documentation https://prometheus.io/docs/prometheus/latest/configuration/configuration/#<alertmanager_config>.
    ## AlertManager configurations specified are appended to the configurations generated by the Prometheus Operator.
    ## As AlertManager configs are appended, the user is responsible to make sure it is valid. Note that using this
    ## feature may expose the possibility to break upgrades of Prometheus. It is advised to review Prometheus release
    ## notes to ensure that no incompatible AlertManager configs are going to break Prometheus after the upgrade.
    ##
    additionalAlertManagerConfigs: []
    # - consul_sd_configs:
    #   - server: consul.dev.test:8500
    #     scheme: http
    #     datacenter: dev
    #     tag_separator: ','
    #     services:
    #       - metrics-prometheus-alertmanager

    ## If additional alertmanager configurations are already deployed in a single secret, or you want to manage
    ## them separately from the helm deployment, you can use this section.
    ## Expected values are the secret name and key
    ## Cannot be used with additionalAlertManagerConfigs
    additionalAlertManagerConfigsSecret: {}
      # name:
      # key:
      # optional: false

    ## AdditionalAlertRelabelConfigs allows specifying Prometheus alert relabel configurations. Alert relabel configurations specified are appended
    ## to the configurations generated by the Prometheus Operator. Alert relabel configurations specified must have the form as specified in the
    ## official Prometheus documentation: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#alert_relabel_configs.
    ## As alert relabel configs are appended, the user is responsible to make sure it is valid. Note that using this feature may expose the
    ## possibility to break upgrades of Prometheus. It is advised to review Prometheus release notes to ensure that no incompatible alert relabel
    ## configs are going to break Prometheus after the upgrade.
    ##
    additionalAlertRelabelConfigs: []
    # - separator: ;
    #   regex: prometheus_replica
    #   replacement: $1
    #   action: labeldrop

    ## If additional alert relabel configurations are already deployed in a single secret, or you want to manage
    ## them separately from the helm deployment, you can use this section.
    ## Expected values are the secret name and key
    ## Cannot be used with additionalAlertRelabelConfigs
    additionalAlertRelabelConfigsSecret: {}
      # name:
      # key:

    ## SecurityContext holds pod-level security attributes and common container settings.
    ## This defaults to non root user with uid 1000 and gid 2000.
    ## https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md
    ##
    securityContext:
      runAsGroup: 2000
      runAsNonRoot: true
      runAsUser: 1000
      fsGroup: 2000
      seccompProfile:
        type: RuntimeDefault

    ## Priority class assigned to the Pods
    ##
    priorityClassName: ""

    ## Thanos configuration allows configuring various aspects of a Prometheus server in a Thanos environment.
    ## This section is experimental, it may change significantly without deprecation notice in any release.
    ## This is experimental and may change significantly without backward compatibility in any release.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#thanosspec
    ##
    thanos: {}
      # secretProviderClass:
      #   provider: gcp
      #   parameters:
      #     secrets: |
      #       - resourceName: "projects/$PROJECT_ID/secrets/testsecret/versions/latest"
      #         fileName: "objstore.yaml"
      ## ObjectStorageConfig configures object storage in Thanos.
      # objectStorageConfig:
      #   # use existing secret, if configured, objectStorageConfig.secret will not be used
      #   existingSecret: {}
      #     # name: ""
      #     # key: ""
      #   # will render objectStorageConfig secret data and configure it to be used by Thanos custom resource,
      #   # ignored when prometheusspec.thanos.objectStorageConfig.existingSecret is set
      #   # https://thanos.io/tip/thanos/storage.md/#s3
      #   secret: {}
      #     # type: S3
      #     # config:
      #     #   bucket: ""
      #     #   endpoint: ""
      #     #   region: ""
      #     #   access_key: ""
      #     #   secret_key: ""

    ## Containers allows injecting additional containers. This is meant to allow adding an authentication proxy to a Prometheus pod.
    ## if using proxy extraContainer update targetPort with proxy container port
    containers: []
    # containers:
    # - name: oauth-proxy
    #   image: quay.io/oauth2-proxy/oauth2-proxy:v7.5.1
    #   args:
    #   - --upstream=http://127.0.0.1:9090
    #   - --http-address=0.0.0.0:8081
    #   - --metrics-address=0.0.0.0:8082
    #   - ...
    #   ports:
    #   - containerPort: 8081
    #     name: oauth-proxy
    #     protocol: TCP
    #   - containerPort: 8082
    #     name: oauth-metrics
    #     protocol: TCP
    #   resources: {}

    ## InitContainers allows injecting additional initContainers. This is meant to allow doing some changes
    ## (permissions, dir tree) on mounted volumes before starting prometheus
    initContainers: []

    ## PortName to use for Prometheus.
    ##
    portName: "http-web"

    ## ArbitraryFSAccessThroughSMs configures whether configuration based on a service monitor can access arbitrary files
    ## on the file system of the Prometheus container e.g. bearer token files.
    arbitraryFSAccessThroughSMs: false

    ## OverrideHonorLabels if set to true overrides all user configured honor_labels. If HonorLabels is set in ServiceMonitor
    ## or PodMonitor to true, this overrides honor_labels to false.
    overrideHonorLabels: false

    ## OverrideHonorTimestamps allows to globally enforce honoring timestamps in all scrape configs.
    overrideHonorTimestamps: false

    ## IgnoreNamespaceSelectors if set to true will ignore NamespaceSelector settings from the podmonitor and servicemonitor
    ## configs, and they will only discover endpoints within their current namespace. Defaults to false.
    ignoreNamespaceSelectors: false

    ## EnforcedNamespaceLabel enforces adding a namespace label of origin for each alert and metric that is user created.
    ## The label value will always be the namespace of the object that is being created.
    ## Disabled by default
    enforcedNamespaceLabel: ""

    ## PrometheusRulesExcludedFromEnforce - list of prometheus rules to be excluded from enforcing of adding namespace labels.
    ## Works only if enforcedNamespaceLabel set to true. Make sure both ruleNamespace and ruleName are set for each pair
    ## Deprecated, use `excludedFromEnforcement` instead
    prometheusRulesExcludedFromEnforce: []

    ## ExcludedFromEnforcement - list of object references to PodMonitor, ServiceMonitor, Probe and PrometheusRule objects
    ## to be excluded from enforcing a namespace label of origin.
    ## Works only if enforcedNamespaceLabel set to true.
    ## See https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#objectreference
    excludedFromEnforcement: []

    ## QueryLogFile specifies the file to which PromQL queries are logged. Note that this location must be writable,
    ## and can be persisted using an attached volume. Alternatively, the location can be set to a stdout location such
    ## as /dev/stdout to log querie information to the default Prometheus log stream. This is only available in versions
    ## of Prometheus >= 2.16.0. For more details, see the Prometheus docs (https://prometheus.io/docs/guides/query-log/)
    queryLogFile: false

    ## EnforcedSampleLimit defines global limit on number of scraped samples that will be accepted. This overrides any SampleLimit
    ## set per ServiceMonitor or/and PodMonitor. It is meant to be used by admins to enforce the SampleLimit to keep overall
    ## number of samples/series under the desired limit. Note that if SampleLimit is lower that value will be taken instead.
    enforcedSampleLimit: false

    ## EnforcedTargetLimit defines a global limit on the number of scraped targets. This overrides any TargetLimit set
    ## per ServiceMonitor or/and PodMonitor. It is meant to be used by admins to enforce the TargetLimit to keep the overall
    ## number of targets under the desired limit. Note that if TargetLimit is lower, that value will be taken instead, except
    ## if either value is zero, in which case the non-zero value will be used. If both values are zero, no limit is enforced.
    enforcedTargetLimit: false


    ## Per-scrape limit on number of labels that will be accepted for a sample. If more than this number of labels are present
    ## post metric-relabeling, the entire scrape will be treated as failed. 0 means no limit. Only valid in Prometheus versions
    ## 2.27.0 and newer.
    enforcedLabelLimit: false

    ## Per-scrape limit on length of labels name that will be accepted for a sample. If a label name is longer than this number
    ## post metric-relabeling, the entire scrape will be treated as failed. 0 means no limit. Only valid in Prometheus versions
    ## 2.27.0 and newer.
    enforcedLabelNameLengthLimit: false

    ## Per-scrape limit on length of labels value that will be accepted for a sample. If a label value is longer than this
    ## number post metric-relabeling, the entire scrape will be treated as failed. 0 means no limit. Only valid in Prometheus
    ## versions 2.27.0 and newer.
    enforcedLabelValueLengthLimit: false

    ## AllowOverlappingBlocks enables vertical compaction and vertical query merge in Prometheus. This is still experimental
    ## in Prometheus so it may change in any upcoming release.
    allowOverlappingBlocks: false

    ## Minimum number of seconds for which a newly created pod should be ready without any of its container crashing for it to
    ## be considered available. Defaults to 0 (pod will be considered available as soon as it is ready).
    minReadySeconds: 0

    # Required for use in managed kubernetes clusters (such as AWS EKS) with custom CNI (such as calico),
    # because control-plane managed by AWS cannot communicate with pods' IP CIDR and admission webhooks are not working
    # Use the host's network namespace if true. Make sure to understand the security implications if you want to enable it.
    # When hostNetwork is enabled, this will set dnsPolicy to ClusterFirstWithHostNet automatically.
    hostNetwork: false

    # HostAlias holds the mapping between IP and hostnames that will be injected
    # as an entry in the pod’s hosts file.
    hostAliases: []
    #  - ip: 10.10.0.100
    #    hostnames:
    #      - a1.app.local
    #      - b1.app.local

    ## TracingConfig configures tracing in Prometheus.
    ## See https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#prometheustracingconfig
    tracingConfig: {}

    ## Additional configuration which is not covered by the properties above. (passed through tpl)
    additionalConfig: {}

    ## Additional configuration which is not covered by the properties above.
    ## Useful, if you need advanced templating inside alertmanagerSpec.
    ## Otherwise, use prometheus.prometheusSpec.additionalConfig (passed through tpl)
    additionalConfigString: ""

  additionalRulesForClusterRole: []
  #  - apiGroups: [ "" ]
  #    resources:
  #      - nodes/proxy
  #    verbs: [ "get", "list", "watch" ]

  additionalServiceMonitors: []
  ## Name of the ServiceMonitor to create
  ##
  # - name: ""

    ## Additional labels to set used for the ServiceMonitorSelector. Together with standard labels from
    ## the chart
    ##
    # additionalLabels: {}

    ## Service label for use in assembling a job name of the form <label value>-<port>
    ## If no label is specified, the service name is used.
    ##
    # jobLabel: ""

    ## labels to transfer from the kubernetes service to the target
    ##
    # targetLabels: []

    ## labels to transfer from the kubernetes pods to the target
    ##
    # podTargetLabels: []

    ## Label selector for services to which this ServiceMonitor applies
    ##
    # selector: {}

    ## Namespaces from which services are selected
    ##
    # namespaceSelector:
      ## Match any namespace
      ##
      # any: false

      ## Explicit list of namespace names to select
      ##
      # matchNames: []

    ## Endpoints of the selected service to be monitored
    ##
    # endpoints: []
      ## Name of the endpoint's service port
      ## Mutually exclusive with targetPort
      # - port: ""

      ## Name or number of the endpoint's target port
      ## Mutually exclusive with port
      # - targetPort: ""

      ## File containing bearer token to be used when scraping targets
      ##
      #   bearerTokenFile: ""

      ## Interval at which metrics should be scraped
      ##
      #   interval: 30s

      ## HTTP path to scrape for metrics
      ##
      #   path: /metrics

      ## HTTP scheme to use for scraping
      ##
      #   scheme: http

      ## TLS configuration to use when scraping the endpoint
      ##
      #   tlsConfig:

          ## Path to the CA file
          ##
          # caFile: ""

          ## Path to client certificate file
          ##
          # certFile: ""

          ## Skip certificate verification
          ##
          # insecureSkipVerify: false

          ## Path to client key file
          ##
          # keyFile: ""

          ## Server name used to verify host name
          ##
          # serverName: ""

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    # metricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    # relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

  additionalPodMonitors: []
  ## Name of the PodMonitor to create
  ##
  # - name: ""

    ## Additional labels to set used for the PodMonitorSelector. Together with standard labels from
    ## the chart
    ##
    # additionalLabels: {}

    ## Pod label for use in assembling a job name of the form <label value>-<port>
    ## If no label is specified, the pod endpoint name is used.
    ##
    # jobLabel: ""

    ## Label selector for pods to which this PodMonitor applies
    ##
    # selector: {}

    ## PodTargetLabels transfers labels on the Kubernetes Pod onto the target.
    ##
    # podTargetLabels: {}

    ## SampleLimit defines per-scrape limit on number of scraped samples that will be accepted.
    ##
    # sampleLimit: 0

    ## Namespaces from which pods are selected
    ##
    # namespaceSelector:
      ## Match any namespace
      ##
      # any: false

      ## Explicit list of namespace names to select
      ##
      # matchNames: []

    ## Endpoints of the selected pods to be monitored
    ## https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#podmetricsendpoint
    ##
    # podMetricsEndpoints: []

## Configuration for thanosRuler
## ref: https://thanos.io/tip/components/rule.md/
##
thanosRuler:

  ## Deploy thanosRuler
  ##
  enabled: false

  ## Annotations for ThanosRuler
  ##
  annotations: {}

  ## Service account for ThanosRuler to use.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
  ##
  serviceAccount:
    create: true
    name: ""
    annotations: {}

  ## Configure pod disruption budgets for ThanosRuler
  ## ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/#specifying-a-poddisruptionbudget
  ## This configuration is immutable once created and will require the PDB to be deleted to be changed
  ## https://github.com/kubernetes/kubernetes/issues/45398
  ##
  podDisruptionBudget:
    enabled: false
    minAvailable: 1
    maxUnavailable: ""

  ingress:
    enabled: false

    # For Kubernetes >= 1.18 you should specify the ingress-controller via the field ingressClassName
    # See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#specifying-the-class-of-an-ingress
    # ingressClassName: nginx

    annotations: {}

    labels: {}

    ## Hosts must be provided if Ingress is enabled.
    ##
    hosts: []
      # - thanosruler.domain.com

    ## Paths to use for ingress rules - one path should match the thanosruler.routePrefix
    ##
    paths: []
    # - /

    ## For Kubernetes >= 1.18 you should specify the pathType (determines how Ingress paths should be matched)
    ## See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#better-path-matching-with-path-types
    # pathType: ImplementationSpecific

    ## TLS configuration for ThanosRuler Ingress
    ## Secret must be manually created in the namespace
    ##
    tls: []
    # - secretName: thanosruler-general-tls
    #   hosts:
    #   - thanosruler.example.com

  ## Configuration for ThanosRuler service
  ##
  service:
    annotations: {}
    labels: {}
    clusterIP: ""

    ## Port for ThanosRuler Service to listen on
    ##
    port: 10902
    ## To be used with a proxy extraContainer port
    ##
    targetPort: 10902
    ## Port to expose on each node
    ## Only used if service.type is 'NodePort'
    ##
    nodePort: 30905
    ## List of IP addresses at which the Prometheus server service is available
    ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
    ##

    ## Additional ports to open for ThanosRuler service
    additionalPorts: []

    externalIPs: []
    loadBalancerIP: ""
    loadBalancerSourceRanges: []

    ## Denotes if this Service desires to route external traffic to node-local or cluster-wide endpoints
    ##
    externalTrafficPolicy: Cluster

    ## Service type
    ##
    type: ClusterIP

  ## If true, create a serviceMonitor for thanosRuler
  ##
  serviceMonitor:
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""
    selfMonitor: true

    ## Additional labels
    ##
    additionalLabels: {}

    ## SampleLimit defines per-scrape limit on number of scraped samples that will be accepted.
    ##
    sampleLimit: 0

    ## TargetLimit defines a limit on the number of scraped targets that will be accepted.
    ##
    targetLimit: 0

    ## Per-scrape limit on number of labels that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelLimit: 0

    ## Per-scrape limit on length of labels name that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelNameLengthLimit: 0

    ## Per-scrape limit on length of labels value that will be accepted for a sample. Only valid in Prometheus versions 2.27.0 and newer.
    ##
    labelValueLengthLimit: 0

    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""

    ## scheme: HTTP scheme to use for scraping. Can be used with `tlsConfig` for example if using istio mTLS.
    scheme: ""

    ## tlsConfig: TLS configuration to use when scraping the endpoint. For example if using istio mTLS.
    ## Of type: https://github.com/coreos/prometheus-operator/blob/main/Documentation/api.md#tlsconfig
    tlsConfig: {}

    bearerTokenFile:

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## Additional Endpoints
    ##
    additionalEndpoints: []
    # - port: oauth-metrics
    #   path: /metrics

  ## Settings affecting thanosRulerpec
  ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#thanosrulerspec
  ##
  thanosRulerSpec:
    ## Standard object's metadata. More info: https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md#metadata
    ## Metadata Labels and Annotations gets propagated to the ThanosRuler pods.
    ##
    podMetadata: {}

    ## Image of ThanosRuler
    ##
    image:
      registry: quay.io
      repository: thanos/thanos
      tag: v0.32.5
      sha: ""

    ## Namespaces to be selected for PrometheusRules discovery.
    ## If nil, select own namespace. Namespaces to be selected for ServiceMonitor discovery.
    ## See https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#namespaceselector for usage
    ##
    ruleNamespaceSelector: {}

    ## If true, a nil or {} value for thanosRuler.thanosRulerSpec.ruleSelector will cause the
    ## prometheus resource to be created with selectors based on values in the helm deployment,
    ## which will also match the PrometheusRule resources created
    ##
    ruleSelectorNilUsesHelmValues: true

    ## PrometheusRules to be selected for target discovery.
    ## If {}, select all PrometheusRules
    ##
    ruleSelector: {}
    ## Example which select all PrometheusRules resources
    ## with label "prometheus" with values any of "example-rules" or "example-rules-2"
    # ruleSelector:
    #   matchExpressions:
    #     - key: prometheus
    #       operator: In
    #       values:
    #         - example-rules
    #         - example-rules-2
    #
    ## Example which select all PrometheusRules resources with label "role" set to "example-rules"
    # ruleSelector:
    #   matchLabels:
    #     role: example-rules

    ## Define Log Format
    # Use logfmt (default) or json logging
    logFormat: logfmt

    ## Log level for ThanosRuler to be configured with.
    ##
    logLevel: info

    ## Size is the expected size of the thanosRuler cluster. The controller will eventually make the size of the
    ## running cluster equal to the expected size.
    replicas: 1

    ## Time duration ThanosRuler shall retain data for. Default is '24h', and must match the regular expression
    ## [0-9]+(ms|s|m|h) (milliseconds seconds minutes hours).
    ##
    retention: 24h

    ## Interval between consecutive evaluations.
    ##
    evaluationInterval: ""

    ## Storage is the definition of how storage will be used by the ThanosRuler instances.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/storage.md
    ##
    storage: {}
    # volumeClaimTemplate:
    #   spec:
    #     storageClassName: gluster
    #     accessModes: ["ReadWriteOnce"]
    #     resources:
    #       requests:
    #         storage: 50Gi
    #   selector: {}

    ## AlertmanagerConfig define configuration for connecting to alertmanager.
    ## Only available with Thanos v0.10.0 and higher. Maps to the alertmanagers.config Thanos Ruler arg.
    alertmanagersConfig:
      # use existing secret, if configured, alertmanagersConfig.secret will not be used
      existingSecret: {}
        # name: ""
        # key: ""
      # will render render alertmanagersConfig secret data and configure it to be used by Thanos Ruler custom resource, ignored when alertmanagersConfig.existingSecret is set
      # https://thanos.io/tip/components/rule.md/#alertmanager
      secret: {}
        # alertmanagers:
        # - api_version: v2
        #   http_config:
        #     basic_auth:
        #       username: some_user
        #       password: some_pass
        #   static_configs:
        #     - alertmanager.thanos.io
        #   scheme: http
        #   timeout: 10s

    ## DEPRECATED. Define URLs to send alerts to Alertmanager. For Thanos v0.10.0 and higher, alertmanagersConfig should be used instead.
    ## Note: this field will be ignored if alertmanagersConfig is specified. Maps to the alertmanagers.url Thanos Ruler arg.
    # alertmanagersUrl:

    ## The external URL the Thanos Ruler instances will be available under. This is necessary to generate correct URLs. This is necessary if Thanos Ruler is not served from root of a DNS name. string false
    ##
    externalPrefix:

    ## The route prefix ThanosRuler registers HTTP handlers for. This is useful, if using ExternalURL and a proxy is rewriting HTTP routes of a request, and the actual ExternalURL is still true,
    ## but the server serves requests under a different route prefix. For example for use with kubectl proxy.
    ##
    routePrefix: /

    ## ObjectStorageConfig configures object storage in Thanos
    objectStorageConfig:
      # use existing secret, if configured, objectStorageConfig.secret will not be used
      existingSecret: {}
        # name: ""
        # key: ""
      # will render objectStorageConfig secret data and configure it to be used by Thanos Ruler custom resource, ignored when objectStorageConfig.existingSecret is set
      # https://thanos.io/tip/thanos/storage.md/#s3
      secret: {}
        # type: S3
        # config:
        #   bucket: ""
        #   endpoint: ""
        #   region: ""
        #   access_key: ""
        #   secret_key: ""

    ## QueryEndpoints defines Thanos querier endpoints from which to query metrics.
    ## Maps to the --query flag of thanos ruler.
    queryEndpoints: []

    ## Define configuration for connecting to thanos query instances. If this is defined, the queryEndpoints field will be ignored.
    ## Maps to the query.config CLI argument. Only available with thanos v0.11.0 and higher.
    queryConfig:
      # use existing secret, if configured, queryConfig.secret will not be used
      existingSecret: {}
        # name: ""
        # key: ""
      # render queryConfig secret data and configure it to be used by Thanos Ruler custom resource, ignored when queryConfig.existingSecret is set
      # https://thanos.io/tip/components/rule.md/#query-api
      secret: {}
        # - http_config:
        #     basic_auth:
        #       username: some_user
        #       password: some_pass
        #   static_configs:
        #     - URL
        #   scheme: http
        #   timeout: 10s

    ## Labels configure the external label pairs to ThanosRuler. A default replica
    ## label `thanos_ruler_replica` will be always added as a label with the value
    ## of the pod's name and it will be dropped in the alerts.
    labels: {}

    ## If set to true all actions on the underlying managed objects are not going to be performed, except for delete actions.
    ##
    paused: false

    ## Define which Nodes the Pods are scheduled on.
    ## ref: https://kubernetes.io/docs/user-guide/node-selection/
    ##
    nodeSelector: {}

    ## Define resources requests and limits for single Pods.
    ## ref: https://kubernetes.io/docs/user-guide/compute-resources/
    ##
    resources: {}
    # requests:
    #   memory: 400Mi

    ## Pod anti-affinity can prevent the scheduler from placing Prometheus replicas on the same node.
    ## The default value "soft" means that the scheduler should *prefer* to not schedule two replica pods onto the same node but no guarantee is provided.
    ## The value "hard" means that the scheduler is *required* to not schedule two replica pods onto the same node.
    ## The value "" will disable pod anti-affinity so that no anti-affinity rules will be configured.
    ##
    podAntiAffinity: ""

    ## If anti-affinity is enabled sets the topologyKey to use for anti-affinity.
    ## This can be changed to, for example, failure-domain.beta.kubernetes.io/zone
    ##
    podAntiAffinityTopologyKey: kubernetes.io/hostname

    ## Assign custom affinity rules to the thanosRuler instance
    ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
    ##
    affinity: {}
    # nodeAffinity:
    #   requiredDuringSchedulingIgnoredDuringExecution:
    #     nodeSelectorTerms:
    #     - matchExpressions:
    #       - key: kubernetes.io/e2e-az-name
    #         operator: In
    #         values:
    #         - e2e-az1
    #         - e2e-az2

    ## If specified, the pod's tolerations.
    ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
    ##
    tolerations: []
    # - key: "key"
    #   operator: "Equal"
    #   value: "value"
    #   effect: "NoSchedule"

    ## If specified, the pod's topology spread constraints.
    ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
    ##
    topologySpreadConstraints: []
    # - maxSkew: 1
    #   topologyKey: topology.kubernetes.io/zone
    #   whenUnsatisfiable: DoNotSchedule
    #   labelSelector:
    #     matchLabels:
    #       app: thanos-ruler

    ## SecurityContext holds pod-level security attributes and common container settings.
    ## This defaults to non root user with uid 1000 and gid 2000. *v1.PodSecurityContext  false
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
    ##
    securityContext:
      runAsGroup: 2000
      runAsNonRoot: true
      runAsUser: 1000
      fsGroup: 2000
      seccompProfile:
        type: RuntimeDefault

    ## ListenLocal makes the ThanosRuler server listen on loopback, so that it does not bind against the Pod IP.
    ## Note this is only for the ThanosRuler UI, not the gossip communication.
    ##
    listenLocal: false

    ## Containers allows injecting additional containers. This is meant to allow adding an authentication proxy to an ThanosRuler pod.
    ##
    containers: []

    # Additional volumes on the output StatefulSet definition.
    volumes: []

    # Additional VolumeMounts on the output StatefulSet definition.
    volumeMounts: []

    ## InitContainers allows injecting additional initContainers. This is meant to allow doing some changes
    ## (permissions, dir tree) on mounted volumes before starting prometheus
    initContainers: []

    ## Priority class assigned to the Pods
    ##
    priorityClassName: ""

    ## PortName to use for ThanosRuler.
    ##
    portName: "web"

  ## ExtraSecret can be used to store various data in an extra secret
  ## (use it for example to store hashed basic auth credentials)
  extraSecret:
    ## if not set, name will be auto generated
    # name: ""
    annotations: {}
    data: {}
  #   auth: |
  #     foo:$apr1$OFG3Xybp$ckL0FHDAkoXYIlH9.cysT0
  #     someoneelse:$apr1$DMZX2Z4q$6SbQIfyuLQd.xmo/P0m2c.

## Setting to true produces cleaner resource names, but requires a data migration because the name of the persistent volume changes. Therefore this should only be set once on initial installation.
##
cleanPrometheusOperatorObjectNames: false

## Extra manifests to deploy as an array
extraManifests: []
  # - apiVersion: v1
  #   kind: ConfigMap
  #   metadata:
  #   labels:
  #     name: prometheus-extra
  #   data:
  #     extra-data: "value"

assertNoLeakedSecrets: false
