resource "helm_release" "kiali" {
  name              = "kiali"
  chart             = "kiali-server"
  repository        = "https://kiali.org/helm-charts"
  version           = "1.84.0"
  timeout           = "600"
  dependency_update = true
  namespace         = "istio-system"
  depends_on        = [module.eks, helm_release.istio_base]
  values = [templatefile("helm-manifests/kiali.tpl", {
    environment   = var.environment,
    client_id     = var.kiali_google_client_id,
    client_secret = var.kiali_google_client_secret
  })]
}