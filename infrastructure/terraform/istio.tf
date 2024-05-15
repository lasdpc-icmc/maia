resource "helm_release" "istio" {
  name              = "istio"
  chart             = "istiod"
  repository        = "https://istio-release.storage.googleapis.com/charts"
  version           = "1.22.0"
  timeout           = "600"
  dependency_update = true
  values            = [templatefile("helm-manifests/loki.tpl", { environment = var.environment })]
  namespace         = "istio-system"
  create_namespace  = true
  depends_on        = [module.eks]
}

