resource "helm_release" "external_secrets" {
  name              = "external-secrets"
  chart             = "external-secrets"
  repository        = "https://charts.external-secrets.io"
  version           = "0.9.11"
  timeout           = "600"
  dependency_update = true
  values            = [templatefile("helm-manifests/external-secrets.tpl", { environment = var.environment })]
  namespace         = "external-secrets"
  create_namespace  = true
  depends_on        = [helm_release.cert_manager]
}