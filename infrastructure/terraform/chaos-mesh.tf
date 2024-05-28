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


resource "kubernetes_manifest" "service_account" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "ServiceAccount"
    "metadata" = {
      "namespace" = "sock-shop"
      "name"      = "account-sock-shop-manager-ispal"
    }

    "automountServiceAccountToken" = true
  }
}

resource "kubernetes_role" "role_sock_shop_manager_ispal" {
  metadata {
    name      = "role-sock-shop-manager-ispal"
    namespace = "sock-shop"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "namespaces"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = ["chaos-mesh.org"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch", "create", "delete", "patch", "update"]
  }
  depends_on = [helm_release.chaos_mesh, kubernetes_service_account.account-sock-shop-manager-ispal]
}

resource "kubernetes_role_binding" "bind_sock_shop_manager_ispal" {
  metadata {
    name      = "bind-sock-shop-manager-ispal"
    namespace = "sock-shop"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "account-sock-shop-manager-ispal"
    namespace = "sock-shop"
  }

  role_ref {
    kind      = "Role"
    name      = "role-sock-shop-manager-ispal"
    api_group = "rbac.authorization.k8s.io"
  }
  depends_on = [helm_release.chaos_mesh, kubernetes_service_account.account-sock-shop-manager-ispal, kubernetes_role.role_sock_shop_manager_ispal]
}
