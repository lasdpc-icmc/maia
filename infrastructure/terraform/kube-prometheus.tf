resource "helm_release" "kube_prometheus" {
  name              = "kube-prometheus"
  repository        = "https://prometheus-community.github.io/helm-charts"
  chart             = "kube-prometheus-stack"
  version           = "55.0.0"
  timeout           = "1500"
  namespace         = "monitoring"
  create_namespace  = true
  dependency_update = true
  depends_on        = [module.eks]
  values = [templatefile("helm-manifests/kube-prometheus.tpl", {
    environment   = var.environment,
    client_id     = var.grafana_client_id,
    client_secret = var.grafana_client_secret
  })]
}

resource "kubernetes_manifest" "monitoring_prod_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    metadata = {
      name      = "monitoring-prod"
      namespace = "monitoring"
    }

    spec = {
      dnsNames = ["grafana-lasdpc.icmc.usp.br"]

      issuerRef = {
        kind = "ClusterIssuer"
        name = "letsencrypt-prod"
      }

      secretName  = "grafana-tls"
      duration    = "8640h"
      renewBefore = "7440h"
    }
  }

  computed_fields = ["spec.duration", "spec.renewBefore"]
  depends_on      = [helm_release.kube_prometheus]
}
