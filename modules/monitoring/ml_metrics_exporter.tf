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
          "kubernetes.io/change-cause" = "Update to metrics exporter with flask and thread starter"
        }
      }

      spec {
        container {
          name  = "ml-metrics-exporter"
          image = "python:3.10-slim"
          
          # Comando para usar o ConfigMap
          command = ["/bin/sh", "-c"]
          args = [
            "pip install -r /app/config/requirements.txt && python /app/config/app.py"
          ]
          
          port {
            container_port = 8080
            name           = "http"
          }
          
          volume_mount {
            name       = "config-volume"
            mount_path = "/app/config"
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

          # Variável de ambiente para garantir que o Flask rode em modo de produção
          env {
            name  = "FLASK_ENV"
            value = "production"
          }

          # Variável de ambiente para definir a porta
          env {
            name  = "PORT"
            value = "8080"
          }

          # Configuração de health check
          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 30
            period_seconds       = 10
          }
          
          readiness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds       = 5
          }
        }

        volume {
          name = "config-volume"
          config_map {
            name = kubernetes_config_map.ml_metrics_exporter_config.metadata[0].name
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