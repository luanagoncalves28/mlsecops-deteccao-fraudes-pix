# Service Account for Prometheus
resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "prometheus"
    }
  }
}

# Config Map for Prometheus
resource "kubernetes_config_map" "prometheus_config" {
  metadata {
    name      = "prometheus-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "prometheus.yml" = file("${path.module}/prometheus-config.yaml")
    "alert_rules.yml" = <<EOF
groups:
- name: MLSecOps
  rules:
  - alert: SystemUnavailable
    expr: up == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Sistema indisponível"
      description: "O sistema está indisponível há mais de 1 minuto."
      
  - alert: HighInferenceLatency
    expr: inference_latency_seconds > 0.2
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "Alta latência de inferência"
      description: "A latência de inferência está acima de 200ms por mais de 2 minutos."
      
  - alert: ModelDriftDetected
    expr: model_drift_score > 0.1
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Drift de modelo detectado"
      description: "Foi detectado drift no modelo com score acima de 0.1."
      
  - alert: HighFalsePositiveRate
    expr: (prediction_fraud_rate / (model_precision + 0.001)) > 0.1
    for: 15m
    labels:
      severity: warning
    annotations:
      summary: "Alta taxa de falsos positivos"
      description: "A taxa de falsos positivos está acima do limiar esperado."
EOF
  }
}

# Adicionando o Deployment do Prometheus
resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "prometheus"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "prometheus"
      }
    }

    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.prometheus.metadata[0].name

        container {
          name  = "prometheus"
          image = "prom/prometheus:v2.45.0"
          args  = ["--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.retention.time=15d"]

          port {
            container_port = 9090
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/prometheus"
          }

          volume_mount {
            name       = "prometheus-data"
            mount_path = "/prometheus"
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "2Gi"
            }
            requests = {
              cpu    = "200m"
              memory = "1Gi"
            }
          }
        }

        volume {
          name = "config-volume"
          config_map {
            name = kubernetes_config_map.prometheus_config.metadata[0].name
          }
        }

        volume {
          name = "prometheus-data"
          empty_dir {}
        }
      }
    }
  }
}

# Adicionando o Service do Prometheus
resource "kubernetes_service" "prometheus_service" {
  metadata {
    name      = "prometheus-service"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "prometheus"
    }
  }

  spec {
    selector = {
      app = "prometheus"
    }

    port {
      name        = "http"
      port        = 9090
      target_port = 9090
    }

    type = "ClusterIP"
  }
}