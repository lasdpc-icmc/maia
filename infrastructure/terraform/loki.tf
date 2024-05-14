resource "helm_release" "loki" {
  name              = "loki"
  chart             = "loki-stack"
  repository        = "https://grafana.github.io/helm-charts"
  version           = "2.9.11"
  timeout           = "600"
  dependency_update = true
  values            = [templatefile("helm-manifests/loki.tpl", { environment = var.environment })]
  namespace         = "monitoring"
  depends_on        = [helm_release.kube_prometheus]
}
