resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "prometheus"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "prometheus"
      }
    }

    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }

      spec {
        container {
          name  = "prometheus"
          image = "prom/prometheus"

          port {
            container_port = 9090
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "prometheus_service" {
  metadata {
    name      = "prometheus-service"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  spec {
    selector = {
      app = "prometheus"
    }

    port {
      name       = "http"
      port       = 9090
      target_port = 9090
    }

    type = "ClusterIP"
  }
}