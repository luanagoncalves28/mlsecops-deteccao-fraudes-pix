# Configuração do ConfigMap para as métricas de ML
resource "kubernetes_config_map" "ml_metrics_exporter_config" {
  metadata {
    name      = "ml-metrics-exporter-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "config.yaml" = <<-EOF
      metrics:
        # Métricas para REQ-MON-*
        - name: inference_latency_seconds
          help: "Latência de inferência do modelo em segundos"
        - name: inference_request_total
          help: "Número total de solicitações de inferência ao modelo"
        - name: uptime
          help: "Tempo de atividade do sistema em segundos"
        - name: fraud_detection_trigger_latency_seconds
          help: "Tempo de resposta para transações com suspeita de fraude"
          
        # Métricas para REQ-ANO-*
        - name: model_precision
          help: "Precision do modelo de detecção de fraude"
        - name: model_recall
          help: "Recall do modelo de detecção de fraude"
        - name: model_drift_score
          help: "Score de drift do modelo ao longo do tempo"
        - name: prediction_fraud_rate
          help: "Taxa de transações classificadas como fraude"
          
        # Métricas para REQ-SEG-003/REQ-EXP-003
        - name: model_version
          help: "Versão atual do modelo em produção"
        - name: prediction_latency_seconds
          help: "Latência das previsões do modelo"
          
        # Métricas para REQ-SEG-*/REQ-MON-005
        - name: http_request_duration_seconds
          help: "Duração das requisições HTTP"
        - name: inference_errors_total
          help: "Total de erros de inferência"
        - name: alertmanager_triggered_alerts
          help: "Número de alertas ativos no sistema"
    EOF
  }
}

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
        termination_grace_period_seconds = 5

        container {
          name  = "ml-metrics-exporter"
          # Usar imagem pública enquanto a customizada não está disponível
          image = "prom/prometheus:v2.45.0"
          
          # Quando sua imagem estiver pronta, descomente esta linha e comente a de cima
          # image = "${var.region}-docker.pkg.dev/${var.project_id}/mlsecpix-images-${var.environment}/ml-metrics-exporter:latest"

          port {
            container_port = 8080
          }

          liveness_probe {
            http_get {
              path = "/metrics"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 30
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/metrics"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/ml-metrics-exporter"
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
          name = "config-volume"
          config_map {
            name = kubernetes_config_map.ml_metrics_exporter_config.metadata[0].name
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