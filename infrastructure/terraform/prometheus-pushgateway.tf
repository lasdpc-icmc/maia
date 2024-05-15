resource "helm_release" "prometheus_pushgateway" {
  name              = "push-gateway"
  repository        = "https://prometheus-community.github.io/helm-charts"
  chart             = "prometheus-pushgateway"
  version           = "2.12.0"
  timeout           = "1500"
  namespace         = "monitoring"
  create_namespace  = true
  dependency_update = true
  depends_on        = [module.eks]
  values = [templatefile("helm-manifests/push-gateway.tpl", {
    environment   = var.environment,
  })]
}
