resource "helm_release" "kube_prometheus" {
  name              = "kube-prometheus"
  repository        = "https://prometheus-community.github.io/helm-charts"
  chart             = "kube-prometheus-stack"
  version           = "58.5.0"
  timeout           = "1500"
  namespace         = "monitoring"
  create_namespace  = true
  dependency_update = true
  depends_on        = [module.eks]
  values = [templatefile("helm-manifests/kube-prometheus.tpl", {
    environment   = var.environment,
    client_id     = var.grafana_client_id,
    client_secret = var.grafana_client_secret,
  })]
}