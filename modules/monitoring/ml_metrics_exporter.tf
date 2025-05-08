# Custom metrics exporter para telemetria ML
resource "kubernetes_deployment" "ml_metrics_exporter" {
  metadata {
    name      = "ml-metrics-exporter"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "ml-metrics-exporter"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ml-metrics-exporter"
      }
    }

    template {
      metadata {
        labels = {
          app = "ml-metrics-exporter"
        }
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "8080"
          "prometheus.io/path"   = "/metrics"
        }
      }

      spec {
        container {
          name  = "ml-metrics-exporter"
          # Usa uma imagem temporária que funciona sem precisar de construção
          # Depois vamos substituir pela nossa imagem personalizada
          image = "prom/prometheus:v2.45.0"
          
          command = ["sh", "-c", "while true; do sleep 30; done"]
          
          # Expose metrics endpoint
          port {
            container_port = 8080
          }
          
          resources {
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "ml_metrics_exporter" {
  metadata {
    name      = "ml-metrics-exporter"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "ml-metrics-exporter"
    }
  }

  spec {
    selector = {
      app = "ml-metrics-exporter"
    }

    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }

    type = "ClusterIP"
  }
}