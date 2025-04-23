# ServiceAccount para Prometheus
resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = "prometheus-server"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = merge(var.labels, {
      "app.kubernetes.io/component" = "monitoring"
      "app.kubernetes.io/name"      = "prometheus"
      "environment"                 = var.environment
    })
  }
}

# ClusterRole para Prometheus
resource "kubernetes_cluster_role" "prometheus" {
  metadata {
    name = "prometheus-server"
    labels = merge(var.labels, {
      "app.kubernetes.io/component" = "monitoring"
      "app.kubernetes.io/name"      = "prometheus"
    })
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "nodes/proxy", "services", "endpoints", "pods"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    non_resource_urls = ["/metrics"]
    verbs             = ["get"]
  }
}

# ClusterRoleBinding para Prometheus
resource "kubernetes_cluster_role_binding" "prometheus" {
  metadata {
    name = "prometheus-server"
    labels = merge(var.labels, {
      "app.kubernetes.io/component" = "monitoring"
      "app.kubernetes.io/name"      = "prometheus"
    })
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.prometheus.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.prometheus.metadata[0].name
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
}

# ConfigMap para configuração do Prometheus
resource "kubernetes_config_map" "prometheus_config" {
  metadata {
    name      = "prometheus-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = merge(var.labels, {
      "app.kubernetes.io/component" = "monitoring"
      "app.kubernetes.io/name"      = "prometheus"
      "environment"                 = var.environment
    })
  }

  data = {
    "prometheus.yml" = <<-EOF
      global:
        scrape_interval: 15s
        evaluation_interval: 15s
        external_labels:
          environment: ${var.environment}
          project: mlsecops-fraud-detection

      rule_files:
        - /etc/prometheus/rules/*.rules

      alerting:
        alertmanagers:
        - static_configs:
          - targets:
            - alertmanager:9093

      scrape_configs:
        - job_name: 'prometheus'
          static_configs:
            - targets: ['localhost:9090']

        - job_name: 'kubernetes-apiservers'
          kubernetes_sd_configs:
            - role: endpoints
          scheme: https
          tls_config:
            ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
          relabel_configs:
            - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
              action: keep
              regex: default;kubernetes;https

        - job_name: 'kubernetes-nodes'
          scheme: https
          tls_config:
            ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
          kubernetes_sd_configs:
            - role: node
          relabel_configs:
            - action: labelmap
              regex: __meta_kubernetes_node_label_(.+)

        - job_name: 'kubernetes-pods'
          kubernetes_sd_configs:
            - role: pod
          relabel_configs:
            - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
              action: keep
              regex: true
            - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
              action: replace
              target_label: __metrics_path__
              regex: (.+)
            - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
              action: replace
              regex: ([^:]+)(?::\\d+)?;(\\d+)
              replacement: $1:$2
              target_label: __address__
            - action: labelmap
              regex: __meta_kubernetes_pod_label_(.+)
            - source_labels: [__meta_kubernetes_namespace]
              action: replace
              target_label: kubernetes_namespace
            - source_labels: [__meta_kubernetes_pod_name]
              action: replace
              target_label: kubernetes_pod_name

        - job_name: 'kubernetes-service-endpoints'
          kubernetes_sd_configs:
            - role: endpoints
          relabel_configs:
            - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
              action: keep
              regex: true
            - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
              action: replace
              target_label: __scheme__
              regex: (https?)
            - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
              action: replace
              target_label: __metrics_path__
              regex: (.+)
            - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
              action: replace
              target_label: __address__
              regex: ([^:]+)(?::\\d+)?;(\\d+)
              replacement: $1:$2
            - action: labelmap
              regex: __meta_kubernetes_service_label_(.+)
            - source_labels: [__meta_kubernetes_namespace]
              action: replace
              target_label: kubernetes_namespace
            - source_labels: [__meta_kubernetes_service_name]
              action: replace
              target_label: kubernetes_name
    EOF

    "recording.rules" = <<-EOF
      groups:
      - name: ml-model-metrics
        rules:
        - record: job:ml_model_prediction_latency_seconds:avg
          expr: avg(ml_model_prediction_latency_seconds) by (job, model_version)
        - record: job:ml_model_prediction_errors_total:rate5m
          expr: sum(rate(ml_model_prediction_errors_total[5m])) by (job, model_version, error_type)
    EOF

    "alerting.rules" = <<-EOF
      groups:
      - name: ml-alerts
        rules:
        - alert: HighPredictionLatency
          expr: ml_model_prediction_latency_seconds > 0.5
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "High prediction latency detected"
            description: "ML model prediction latency is above 500ms for 5 minutes."
            
        - alert: ModelDriftDetected
          expr: ml_model_feature_drift_score > 0.1
          for: 15m
          labels:
            severity: warning
          annotations:
            summary: "Model drift detected"
            description: "Feature drift score is above threshold for 15 minutes."
            
        - alert: HighErrorRate
          expr: rate(ml_model_prediction_errors_total[5m]) / rate(ml_model_predictions_total[5m]) > 0.05
          for: 5m
          labels:
            severity: critical
          annotations:
            summary: "High prediction error rate"
            description: "Error rate is above 5% for 5 minutes."
    EOF
  }
}

# PersistentVolumeClaim para Prometheus
resource "kubernetes_persistent_volume_claim" "prometheus" {
  metadata {
    name      = "prometheus-data"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = merge(var.labels, {
      "app.kubernetes.io/component" = "monitoring"
      "app.kubernetes.io/name"      = "prometheus"
      "environment"                 = var.environment
    })
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.storage_size
      }
    }
    storage_class_name = "standard"
  }
}

# Deployment para Prometheus
resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus-server"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = merge(var.labels, {
      "app.kubernetes.io/component" = "monitoring"
      "app.kubernetes.io/name"      = "prometheus"
      "environment"                 = var.environment
    })
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "prometheus-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "prometheus-server"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.prometheus.metadata[0].name

        container {
          name  = "prometheus"
          image = "prom/prometheus:v2.45.0"
          args  = [
            "--config.file=/etc/prometheus/prometheus.yml",
            "--storage.tsdb.path=/prometheus",
            "--storage.tsdb.retention.time=${var.retention_days}d",
            "--web.console.libraries=/etc/prometheus/console_libraries",
            "--web.console.templates=/etc/prometheus/consoles",
            "--web.enable-lifecycle"
          ]

          port {
            container_port = 9090
          }

          volume_mount {
            name       = "prometheus-config"
            mount_path = "/etc/prometheus"
          }

          volume_mount {
            name       = "prometheus-storage"
            mount_path = "/prometheus"
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/-/healthy"
              port = 9090
            }
            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

          readiness_probe {
            http_get {
              path = "/-/ready"
              port = 9090
            }
            initial_delay_seconds = 30
            timeout_seconds       = 30
          }
        }

        volume {
          name = "prometheus-config"
          config_map {
            name = kubernetes_config_map.prometheus_config.metadata[0].name
            items {
              key  = "prometheus.yml"
              path = "prometheus.yml"
            }
            items {
              key  = "recording.rules"
              path = "rules/recording.rules"
            }
            items {
              key  = "alerting.rules"
              path = "rules/alerting.rules"
            }
          }
        }

        volume {
          name = "prometheus-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.prometheus.metadata[0].name
          }
        }
      }
    }
  }
}

# Service para Prometheus
resource "kubernetes_service" "prometheus" {
  metadata {
    name      = "prometheus-service"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = merge(var.labels, {
      "app.kubernetes.io/component" = "monitoring"
      "app.kubernetes.io/name"      = "prometheus"
      "environment"                 = var.environment
    })
  }

  spec {
    selector = {
      app = "prometheus-server"
    }

    port {
      port        = 9090
      target_port = 9090
      name        = "http"
    }

    type = "ClusterIP"
  }
}