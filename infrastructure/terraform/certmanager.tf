resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  chart      = "cert-manager"
  version    = "1.13.3"
  repository = "https://charts.jetstack.io"
  values = [templatefile("helm-manifests/cert-manager.tpl", {
    environment = var.environment
  })]
  namespace        = "cert-manager"
  create_namespace = true
  depends_on       = [module.eks]
}
