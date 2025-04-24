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

# Deployment para o exporter customizado de métricas de ML - Recriação completa
resource "kubernetes_deployment" "ml_metrics_exporter" {
  metadata {
    name      = "ml-metrics-exporter"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    
    # Adiciona um timestamp para forçar a recriação a cada apply
    annotations = {
      "recreate-trigger" = "${timestamp()}"
    }
  }

  # Força a substituição do recurso em vez de tentar atualizá-lo
  lifecycle {
    create_before_destroy = true
  }

  # Reduza o timeout para evitar esperar muito tempo pela criação
  timeouts {
    create = "30s"
  }

  spec {
    # Estratégia de atualização "Recreate" em vez de "RollingUpdate"
    strategy {
      type = "Recreate"
    }
    
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
        
        # Adiciona um timestamp como anotação para forçar a recriação do pod
        annotations = {
          "recreate-trigger" = "${timestamp()}"
        }
      }

      spec {
        termination_grace_period_seconds = 10

        container {
          name  = "ml-metrics-exporter"
          # Usa uma imagem extremamente leve
          image = "busybox:1.36"
          command = ["sh", "-c", "echo 'ML Metrics Exporter placeholder container'; sleep infinity"]

          port {
            container_port = 8080
          }

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