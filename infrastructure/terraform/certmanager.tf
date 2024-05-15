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

variable "manifests_path" {
  default = "certs/prod"
}

locals {
  yaml_files = fileset(var.manifests_path, "*.yaml")
}

data "local_file" "manifests" {
  for_each = local.yaml_files

  filename = "${var.manifests_path}/${each.value}"
}

resource "kubectl_manifest" "apply_manifests" {
  for_each = data.local_file.manifests

  yaml_body  = each.value.content
  depends_on = [helm_release.cert_manager]
}
