resource "helm_release" "tempo" {
  name              = "tempo"
  chart             = "tempo"
  repository        = "https://grafana.github.io/helm-charts"
  version           = "1.7.1"
  timeout           = "600"
  dependency_update = true
  values            = [templatefile("helm-manifests/tempo.tpl", { environment = var.environment })]
  namespace         = "monitoring"
  depends_on        = [helm_release.kube_prometheus]
}
