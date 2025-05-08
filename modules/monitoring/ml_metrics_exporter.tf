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
          # Usar a imagem mais recente do Artifact Registry
          image = "southamerica-east1-docker.pkg.dev/mlsecpix-456600/mlsecpix-images-dev/ml-metrics-exporter:latest"
          
          # Porta para nossa aplicação Flask
          port {
            container_port = 8080
            name           = "http"
          }
          
          # Recursos mais adequados para nosso exporter
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

  # Adicionando timeout mais longo para evitar erros de deadline
  timeouts {
    create = "10m"
    update = "10m"
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