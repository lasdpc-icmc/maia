resource "helm_release" "chaos_mesh" {
  name              = "chaos-mesh"
  chart             = "chaos-mesh"
  repository        = "https://charts.chaos-mesh.org"
  version           = "2.6.3"
  timeout           = "600"
  dependency_update = true
  values            = [templatefile("helm-manifests/chaos-mesh.tpl", { environment = var.environment })]
  namespace         = "chaos-mesh"
  create_namespace  = true
  depends_on        = [module.eks]
}