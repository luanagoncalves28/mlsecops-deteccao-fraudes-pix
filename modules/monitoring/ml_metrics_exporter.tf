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
      }

      spec {
        container {
          name  = "ml-metrics-exporter"
          # Usar uma imagem simples e leve que certamente vai iniciar
          image = "python:3.9-alpine"
          
          # Comando simples para manter o container rodando
          command = ["sh", "-c", "while true; do sleep 30; done"]
          
          resources {
            limits = {
              cpu    = "50m"
              memory = "64Mi"
            }
            requests = {
              cpu    = "10m"
              memory = "32Mi"
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