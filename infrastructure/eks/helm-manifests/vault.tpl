# Vault Helm Chart Value Overrides
global:
  hostNetwork: true
  enabled: true
  tlsDisable: false

injector:
  enabled: true
  # Use the Vault K8s Image https://github.com/hashicorp/vault-k8s/
  image:
    repository: "hashicorp/vault-k8s"
    tag: "0.14.1"

  resources:
      requests:
        memory: 50Mi
        cpu: 50m
      limits:
        memory: 256Mi
        cpu: 250m

server:
  image:
    repository: "hashicorp/vault"
    tag: "1.11.1"

  # These Resource Limits are in line with node requirements in the
  # Vault Reference Architecture for a Small Cluster
  resources:
    requests:
      memory: 50Mi
      cpu: 50m
    limits:
      memory: 512Mi
      cpu: 500m

  # For HA configuration and because we need to manually init the vault,
  # we need to define custom readiness/liveness Probe settings
  readinessProbe:
    enabled: true
    path: "/v1/sys/health?standbyok=true&sealedcode=204&uninitcode=204"
  livenessProbe:
    enabled: true
    path: "/v1/sys/health?standbyok=true"
    initialDelaySeconds: 60

  # extraEnvironmentVars is a list of extra environment variables to set with the stateful set. These could be
  # used to include variables required for auto-unseal.
  extraEnvironmentVars:
    VAULT_CACERT: /vault/userconfig/tls-ca/tls.crt

  # extraVolumes is a list of extra volumes to mount. These will be exposed
  # to Vault in the path `/vault/userconfig/<name>/`.
  extraVolumes:
    - type: secret
      name: tls-server
    - type: secret
      name: tls-ca

  standalone:
    enabled: false

  # Run Vault in "HA" mode.
  ha:
    enabled: true
    replicas: 3
    config: |
      ui = true
       
      listener "tcp" {
        tls_disable = 0
        address     = "0.0.0.0:8200"
        tls_cert_file = "/vault/userconfig/tls-server/tls.crt"
        tls_key_file = "/vault/userconfig/tls-server/tls.key"
        tls_min_version = "tls12"
      }

      storage "consul" {
        path = "vault"
        address = "consul-server.vault:8500"
        check_timeout = "60s"
      }

      seal "awskms" {
      region     = "${region}"
      access_key = "${access_key}"
      secret_key = "${secret_key}"
      kms_key_id = "${kms_key_id}"
      }

  ingress:
    enabled: true
    labels: {}
      # traffic: external
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/backend-protocol: HTTPS
      nginx.ingress.kubernetes.io/ssl-redirect: "false"
      nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
      nginx.ingress.kubernetes.io/rewrite-target: /

    # As of Kubernetes 1.19, all Ingress Paths must have a pathType configured. The default value below should be sufficient in most cases.
    # See: https://kubernetes.io/docs/concepts/services-networking/ingress/#path-types for other possible values.
    pathType: Prefix

    # When HA mode is enabled and K8s service registration is being used,
    # configure the ingress to point to the Vault active service.
    activeService: false

    hosts:
      - host: vault-lasdpc.icmc.usp.br
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: vault
                port:
                  number: 8200
    tls:
      - secretName: vault-tls-secret
        hosts:
        - vault-lasdpc.icmc.usp.br

# Vault UI
ui:
  # True if you want to create a Service entry for the Vault UI.
  #
  # serviceType can be used to control the type of service created. For
  # example, setting this to "LoadBalancer" will create an external load
  # balancer (for supported K8S installations) to access the UI.
  enabled: true
  publishNotReadyAddresses: true
  # The service should only contain selectors for active Vault pod
  activeVaultPodOnly: false
  serviceType: "NodePort"
  serviceNodePort: null
  externalPort: 443
  targetPort: 8200

  # The externalTrafficPolicy can be set to either Cluster or Local
  # and is only valid for LoadBalancer and NodePort service types.
  # The default value is Cluster.
  # ref: https://kubernetes.io/docs/concepts/services-networking/service/#external-traffic-policy
  externalTrafficPolicy: Cluster
  

