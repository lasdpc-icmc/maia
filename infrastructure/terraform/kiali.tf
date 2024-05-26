resource "helm_release" "kiali" {
  name              = "kiali"
  chart             = "kiali-server"
  repository        = "https://kiali.org/helm-charts"
  version           = "1.84.0"
  timeout           = "600"
  dependency_update = true
  values            = [templatefile("helm-manifests/kiali.tpl", { environment = var.environment })]
  namespace         = "istio-system"
  depends_on        = [module.eks, helm_release.istio_base]
}