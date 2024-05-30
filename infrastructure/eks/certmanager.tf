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

resource "kubernetes_manifest" "letsencrypt_prod_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }

    spec = {
      acme = {
        email  = "diegopedroso@usp.br"
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "secret-tls-key"
        }
        solvers = [{
          http01 = {
            ingress = {
              ingressClassName = "nginx"
            }
          }
        }]
      }
    }
  }
  depends_on = [helm_release.cert_manager]
}