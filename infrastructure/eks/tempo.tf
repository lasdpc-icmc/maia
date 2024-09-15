resource "helm_release" "tempo" {
  name              = "tempo"
  chart             = "tempo"
  repository        = "https://grafana.github.io/helm-charts"
  version           = "1.10.3"
  timeout           = "600"
  dependency_update = true
  values            = [templatefile("helm-manifests/tempo.tpl", { environment = var.environment })]
  namespace         = "istio-system"
  depends_on        = [helm_release.kube_prometheus]
}

resource "kubernetes_service" "tempo_zipkin_service" {
  metadata {
    name      = "zipkin"
    namespace = "istio-system"
  }
  spec {
    selector = {
      "app.kubernetes.io/name" = "tempo"
    }

    port {
      port        = 9411
      target_port = 9411
      name        = "tempo-zipkin"
    }

    type = "ClusterIP"
  }
}
