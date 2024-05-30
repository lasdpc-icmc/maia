resource "helm_release" "ingress_nginx" {
  name              = "ingress-nginx"
  chart             = "ingress-nginx"
  repository        = "https://kubernetes.github.io/ingress-nginx"
  version           = "4.9.1"
  timeout           = "600"
  dependency_update = true
  values            = [templatefile("helm-manifests/ingress-nginx.tpl", { environment = var.environment })]
  namespace         = "ingress-nginx"
  create_namespace  = true
  depends_on        = [module.eks]
}