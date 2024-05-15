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

data "local_file" "manifests" {
  count    = length(fileset(var.manifests_path, "*.yaml"))
  filename = "${var.manifests_path}/${fileset(var.manifests_path, "*.yaml")[count.index]}"
}

resource "kubectl_manifest" "apply_manifests" {
  count      = length(data.local_file.manifests)
  yaml_body  = data.local_file.manifests[count.index].content
  depends_on = [helm_release.cert_manager]
}