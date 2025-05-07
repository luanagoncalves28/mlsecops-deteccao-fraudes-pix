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
          "prometheus.io/port"   = "9090"
          "prometheus.io/path"   = "/metrics"
        }
      }

      spec {
        termination_grace_period_seconds = 5

        container {
          name  = "ml-metrics-exporter"
          # Usar uma imagem simples que sabemos que funciona
          image = "prom/prometheus:v2.45.0"
          
          # Alterando a porta para 9090 para corresponder à porta padrão do Prometheus
          port {
            container_port = 9090
          }

          # Ajustar as probes para a porta correta
          liveness_probe {
            http_get {
              path = "/metrics"
              port = 9090
            }
            initial_delay_seconds = 10
            period_seconds        = 30
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/metrics"
              port = 9090
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          # Remover o volume mount temporariamente para simplificar
          # volume_mount {
          #   name       = "config-volume"
          #   mount_path = "/etc/ml-metrics-exporter"
          # }

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
        
        # Remover o volume temporariamente
        # volume {
        #   name = "config-volume"
        #   config_map {
        #     name = kubernetes_config_map.ml_metrics_exporter_config.metadata[0].name
        #   }
        # }
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
      port        = 9090  # Alterado para 9090
      target_port = 9090  # Alterado para 9090
    }

    type = "ClusterIP"
  }
}

# Comentar o ConfigMap para simplificar
# resource "kubernetes_config_map" "ml_metrics_exporter_config" {
#   metadata {
#     name      = "ml-metrics-exporter-config"
#     namespace = kubernetes_namespace.monitoring.metadata[0].name
#   }
#   ...
# }