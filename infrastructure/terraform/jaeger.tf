resource "helm_release" "jaeger" {
  name              = "jaeger"
  chart             = "jaeger"
  repository        = "https://jaegertracing.github.io/helm-charts"
  version           = "3.0.7"
  timeout           = "600"
  dependency_update = true
  values            = [templatefile("helm-manifests/jaeger.tpl", { environment = var.environment })]
  namespace         = "istio-system"
  depends_on        = [module.eks, helm_release.istio_base]
}
