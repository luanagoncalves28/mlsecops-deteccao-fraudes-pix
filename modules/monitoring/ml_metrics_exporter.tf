# ConfigMap para o exporter customizado de métricas de ML
resource "kubernetes_config_map" "ml_metrics_exporter_config" {
  metadata {
    name      = "ml-metrics-exporter-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = merge(var.labels, {
      "app.kubernetes.io/component" = "monitoring"
      "app.kubernetes.io/name"      = "ml-metrics-exporter"
      "environment"                 = var.environment
    })
  }

  data = {
    "config.yaml" = <<-EOF
      exporter:
        port: 8080
        metrics_path: /metrics
        
      metrics:
        - name: ml_model_prediction_latency_seconds
          type: gauge
          help: "Latência de model predictions em segundos"
          labels:
            - model_version
            - model_name
            
        - name: ml_model_predictions_total
          type: counter
          help: "Número total de predições feitas pelo modelo"
          labels:
            - model_version
            - model_name
            - result
            
        - name: ml_model_prediction_errors_total
          type: counter
          help: "Número total de erros de predição"
          labels:
            - model_version
            - model_name
            - error_type
            
        - name: ml_model_feature_drift_score
          type: gauge
          help: "Score indicando drift nas distribuições de features"
          labels:
            - feature_name
            - model_version
            
        - name: ml_model_feature_importance
          type: gauge
          help: "Valores de importância de features"
          labels:
            - feature_name
            - model_version
    EOF
  }
}

# Deployment para o exporter customizado de métricas de ML (simulado para demonstração)
resource "kubernetes_deployment" "ml_metrics_exporter" {
  metadata {
    name      = "ml-metrics-exporter"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = merge(var.labels, {
      "app.kubernetes.io/component" = "monitoring"
      "app.kubernetes.io/name"      = "ml-metrics-exporter"
      "environment"                 = var.environment
    })
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
          image = "prom/prometheus:v2.45.0"  # Na implementação real, seria uma imagem customizada
          args  = [
            "--config.file=/etc/prometheus/prometheus.yml",
            "--web.listen-address=:8080",
            "--web.enable-lifecycle"
          ]

          # Na implementação real, este container executaria um código que expõe métricas do modelo ML
          # Para o demo, usamos uma imagem Prometheus como placeholder

          port {
            container_port = 8080
          }

          volume_mount {
            name       = "exporter-config"
            mount_path = "/etc/prometheus"
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
    labels = merge(var.labels, {
      "app.kubernetes.io/component" = "monitoring"
      "app.kubernetes.io/name"      = "ml-metrics-exporter"
      "environment"                 = var.environment
    })
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