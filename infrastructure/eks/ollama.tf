resource "helm_release" "ollama" {
  name              = "open-webui"
  chart             = "open-webui"
  repository        = "https://helm.openwebui.com"
  version           = "3.0.4"
  timeout           = "600"
  dependency_update = true
  values            = [templatefile("helm-manifests/ollama.tpl", { environment = var.environment })]
  namespace         = "ollama"
  create_namespace  = true
  depends_on        = [helm_release.cert_manager]
}

resource "kubernetes_manifest" "ollama_prod_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    metadata = {
      name      = "ollama-cert-prod"
      namespace = "ollama"
    }

    spec = {
      dnsNames = ["maia-lasdpc.icmc.usp.br"]

      issuerRef = {
        kind = "ClusterIssuer"
        name = "letsencrypt-prod"
      }

      secretName  = "ollama-tls-secret"
      duration    = "8640h"
      renewBefore = "7440h"
    }
  }

  computed_fields = ["spec.duration", "spec.renewBefore"]
  depends_on      = [helm_release.ollama]
}
