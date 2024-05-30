resource "helm_release" "opencost" {
  name              = "opencost"
  chart             = "opencost"
  repository        = "https://opencost.github.io/opencost-helm-chart"
  version           = "1.27.0"
  timeout           = "600"
  dependency_update = true
  values            = [templatefile("helm-manifests/opencost.tpl", { environment = var.environment })]
  namespace         = "opencost"
  create_namespace  = true
  depends_on        = [helm_release.kube_prometheus]
}