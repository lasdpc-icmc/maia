nameOverride: ""
namespaceOverride: ""

ollama:
  # -- Automatically install Ollama Helm chart from https://otwld.github.io/ollama-helm/. Use [Helm Values](https://github.com/otwld/ollama-helm/#helm-values) to configure
  enabled: false
  # -- If enabling embedded Ollama, update fullnameOverride to your desired Ollama name value, or else it will use the default ollama.name value from the Ollama chart
  fullnameOverride: "open-webui-ollama"
  # -- Example Ollama configuration with nvidia GPU enabled, automatically downloading a model, and deploying a PVC for model persistence
  # ollama:
  #   gpu:
  #     enabled: true
  #     type: 'nvidia'
  #     number: 1
  #   models:
  #     - llama3
  # runtimeClassName: nvidia
  # persistentVolume:
  #   enabled: true
  #   volumeName: "example-pre-existing-pv-created-by-smb-csi"

pipelines:
  # -- Automatically install Pipelines chart to extend Open WebUI functionality using Pipelines: https://github.com/open-webui/pipelines
  enabled: false
  # -- This section can be used to pass required environment variables to your pipelines (e.g. Langfuse hostname)
  extraEnvVars: []

tika:
  # -- Automatically install Apache Tika to extend Open WebUI
  enabled: false

# -- A list of Ollama API endpoints. These can be added in lieu of automatically installing the Ollama Helm chart, or in addition to it.
ollamaUrls:
  - http://200.18.99.63:9003

# -- Value of cluster domain
clusterDomain: cluster.local

annotations: {}
podAnnotations: {}
podLabels: {}
replicaCount: 1
# -- Strategy for updating the workload manager: deployment or statefulset
strategy: {}
# -- Open WebUI image tags can be found here: https://github.com/open-webui/open-webui
image:
  repository: ghcr.io/open-webui/open-webui
  tag: v0.4.0
  pullPolicy: "IfNotPresent"

serviceAccount:
  enable: true
  name: ""
  annotations: {}
  automountServiceAccountToken: false

# -- Configure imagePullSecrets to use private registry
# ref: <https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry>
imagePullSecrets: []
# imagePullSecrets:
# - name: myRegistryKeySecretName

# -- Probe for liveness of the Open WebUI container
# ref: <https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes>
livenessProbe: {}
# livenessProbe:
#   httpGet:
#     path: /health
#     port: http
#   failureThreshold: 1
#   periodSeconds: 10

# -- Probe for readiness of the Open WebUI container
# ref: <https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes>
readinessProbe: {}
# readinessProbe:
#   httpGet:
#     path: /health/db
#     port: http
#   failureThreshold: 1
#   periodSeconds: 10

# -- Probe for startup of the Open WebUI container
# ref: <https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes>
startupProbe: {}
# startupProbe:
#   httpGet:
#     path: /health
#     port: http
#   initialDelaySeconds: 30
#   periodSeconds: 5
#   failureThreshold: 20

resources: {}

copyAppData:
  resources: {}

ingress:
  enabled: true
  # -- Use appropriate annotations for your Ingress controller, e.g., for NGINX:
  # nginx.ingress.kubernetes.io/rewrite-target: /
  annotations:
    kubernetes.io/ingress.class: nginx

  host: "maia-lasdpc.icmc.usp.br"
  tls: true

  existingSecret: ollama-tls-secret
persistence:
  enabled: true
  size: 10Gi
  # -- Use existingClaim if you want to re-use an existing Open WebUI PVC instead of creating a new one
  existingClaim: ""
  # -- If using multiple replicas, you must update accessModes to ReadWriteMany
  accessModes:
    - ReadWriteOnce
  storageClass: ""
  selector: {}
  annotations: {}

# -- Node labels for pod assignment.
nodeSelector: {}

# -- Tolerations for pod assignment
tolerations: []

# -- Affinity for pod assignment
affinity: {}

# -- Topology Spread Constraints for pod assignment
topologySpreadConstraints: []

# -- Service values to expose Open WebUI pods to cluster
service:
  type: ClusterIP
  annotations: {}
  port: 80
  containerPort: 8080
  nodePort: ""
  labels: {}
  loadBalancerClass: ""

# -- OpenAI base API URL to use. Defaults to the Pipelines service endpoint when Pipelines are enabled, and "https://api.openai.com/v1" if Pipelines are not enabled and this value is blank
openaiBaseApiUrl: ""

# -- Env vars added to the Open WebUI deployment. Most up-to-date environment variables can be found here: https://docs.openwebui.com/getting-started/env-configuration/
extraEnvVars:
  # -- Default API key value for Pipelines. Should be updated in a production deployment, or be changed to the required API key if not using Pipelines
  - name: OPENAI_API_KEY
    value: "0p3n-w3bu!"
  # valueFrom:
  #   secretKeyRef:
  #     name: pipelines-api-key
  #     key: api-key
  # - name: OPENAI_API_KEY
  #   valueFrom:
  #     secretKeyRef:
  #       name: openai-api-key
  #       key: api-key
  # - name: OLLAMA_DEBUG
  #   value: "1"

# -- Configure container volume mounts
# ref: <https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/>
volumeMounts:
  initContainer: []
  # - name: ""
  #   mountPath: ""
  container: []
  # - name: ""
  #   mountPath: ""

# -- Configure pod volumes
# ref: <https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/>
volumes: []
# - name: ""
#   configMap:
#     name: ""
# - name: ""
#   emptyDir: {}

# -- Configure pod security context
# ref: <https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-containe>
podSecurityContext:
  {}
  # fsGroupChangePolicy: Always
  # sysctls: []
  # supplementalGroups: []
  # fsGroup: 1001


# -- Configure container security context
# ref: <https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-containe>
containerSecurityContext:
  {}
  # runAsUser: 1001
  # runAsGroup: 1001
  # runAsNonRoot: true
  # privileged: false
  # allowPrivilegeEscalation: false
  # readOnlyRootFilesystem: false
  # capabilities:
  #   drop:
  #     - ALL
  # seccompProfile:
  #   type: "RuntimeDefault"