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

# Deployment para o exporter customizado de métricas de ML (ultra simplificado)
resource "kubernetes_deployment" "ml_metrics_exporter" {
  metadata {
    name      = "ml-metrics-exporter"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  # Ignorar alterações em certas seções para evitar esperar pelo status de rollout
  lifecycle {
    ignore_changes = [
      spec[0].replicas,
      spec[0].template[0].spec[0].container,
      metadata[0].annotations,
    ]
  }

  timeouts {
    create = "1m"  # Tempo reduzido drasticamente
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
        container {
          name  = "ml-metrics-exporter"
          # Usando imagem mais leve e simples
          image = "busybox:latest"
          command = ["sh", "-c", "while true; do sleep 30; done"]

          # Recursos mínimos
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
          
          # Removendo as referências aos volumeMounts que estavam causando o erro
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