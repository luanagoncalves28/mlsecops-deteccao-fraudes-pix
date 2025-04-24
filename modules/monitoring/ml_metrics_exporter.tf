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

# Deployment para o exporter customizado de métricas de ML - Versão minimalista
resource "kubernetes_deployment" "ml_metrics_exporter" {
  metadata {
    name      = "ml-metrics-exporter"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    
    # Versão estática para controlar a atualização
    annotations = {
      "deployment-version" = "v1-minimal"
    }
  }

  # Força uma destruição antes de tentar recriar
  lifecycle {
    replace_triggered_by = [
      # Usando o hash do namespace como trigger para substituição
      kubernetes_namespace.monitoring.metadata[0].name
    ]
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
      }

      spec {
        # Configurando terminação rápida
        termination_grace_period_seconds = 5

        container {
          name  = "ml-metrics-exporter"
          image = "busybox:1.36"
          command = ["sh", "-c", "while true; do sleep 3600; done"]

          port {
            container_port = 8080
          }

          resources {
            limits = {
              cpu    = "10m"
              memory = "32Mi"
            }
            requests = {
              cpu    = "5m"
              memory = "16Mi"
            }
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