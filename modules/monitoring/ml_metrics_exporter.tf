# ConfigMap para o exporter customizado de métricas de ML
resource "kubernetes_config_map" "ml_metrics_exporter_config" {
  metadata {
    name      = "ml-metrics-exporter-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "config.yaml" = <<-EOF
      exporter:
        port: 8080
        metrics_path: /metrics
    EOF
  }
}

# Deployment para o exporter customizado de métricas de ML (simplificado)
resource "kubernetes_deployment" "ml_metrics_exporter" {
  metadata {
    name      = "ml-metrics-exporter"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  timeouts {
    create = "3m"
    update = "3m"
    delete = "3m"
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
          # Usando imagem mais leve
          image = "prom/prometheus:v2.45.0"
          args  = [
            "--config.file=/etc/prometheus/prometheus.yml",
            "--web.listen-address=:8080",
            "--web.enable-lifecycle"
          ]

          port {
            container_port = 8080
          }

          volume_mount {
            name       = "exporter-config"
            mount_path = "/etc/prometheus"
          }

          # Recursos mínimos
          resources {
            limits = {
              cpu    = "50m"
              memory = "64Mi"
            }
            requests = {
              cpu    = "20m"
              memory = "32Mi"
            }
          }
        }

        volume {
          name = "exporter-config"
          config_map {
            name = kubernetes_config_map.ml_metrics_exporter_config.metadata[0].name
          }
        }
      }
    }
  }
}

# Service para o exporter de métricas de ML
resource "kubernetes_service" "ml_metrics_exporter" {
  metadata {
    name      = "ml-metrics-exporter"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  spec {
    selector = {
      app = "ml-metrics-exporter"
    }

    port {
      port        = 8080
      target_port = 8080
      name        = "http"
    }

    type = "ClusterIP"
  }
}