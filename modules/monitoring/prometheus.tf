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

# RBAC para o Prometheus acessar recursos do cluster
resource "kubernetes_cluster_role" "prometheus" {
  metadata {
    name = "prometheus-role"
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

resource "kubernetes_cluster_role_binding" "prometheus" {
  metadata {
    name = "prometheus-role-binding"
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

# Config Map for Prometheus
resource "kubernetes_config_map" "prometheus_config" {
  metadata {
    name      = "prometheus-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "prometheus.yml" = <<EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

# Configuração do Alertmanager
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - alertmanager:9093

# Carrega as regras uma vez e as avalia periodicamente
rule_files:
  - "/etc/prometheus/alert_rules.yml"

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
      insecure_skip_verify: true
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
    - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
      action: keep
      regex: default;kubernetes;https

  - job_name: 'kubernetes-nodes'
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      insecure_skip_verify: true
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    kubernetes_sd_configs:
    - role: node
    relabel_configs:
    - action: labelmap
      regex: __meta_kubernetes_node_label_(.+)
    - target_label: __address__
      replacement: kubernetes.default.svc:443
    - source_labels: [__meta_kubernetes_node_name]
      regex: (.+)
      target_label: __metrics_path__
      replacement: /api/v1/nodes/$${1}/proxy/metrics

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
      regex: ([^:]+)(?::\d+)?;(\d+)
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
      regex: ([^:]+)(?::\d+)?;(\d+)
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
  
  - alert: ModelExplainabilityLow
    expr: model_explainability_score < 0.8
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Baixa explicabilidade do modelo"
      description: "O score de explicabilidade do modelo está abaixo do limiar regulatório de 0.8."
      
  - alert: DataRetentionNonCompliant
    expr: data_retention_compliance != 1
    for: 1h
    labels:
      severity: critical
    annotations:
      summary: "Não conformidade na retenção de dados"
      description: "O sistema de retenção de dados não está em conformidade com a política regulatória BCB n° 403."
      
  - alert: DictIntegrationFailure
    expr: dict_integration_status{operation_type="query"} == 0 or dict_integration_status{operation_type="update"} == 0
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "Falha na integração com DICT"
      description: "A integração com o Diretório de Identificadores de Contas Transacionais (DICT) falhou."
      
  - alert: AuditLoggingIncomplete
    expr: audit_log_integrity != 1
    for: 10m
    labels:
      severity: critical
    annotations:
      summary: "Logs de auditoria incompletos"
      description: "A integridade dos logs de auditoria foi comprometida, violando os requisitos de imutabilidade e rastreabilidade."
      
  - alert: ModelResponseTimeSlow
    expr: histogram_quantile(0.95, sum(rate(inference_latency_seconds_bucket[5m])) by (le)) > 0.2
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Tempo de resposta do modelo lento"
      description: "O tempo de resposta do modelo está acima do limiar regulatório (p95 > 200ms)."
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
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "9090"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.prometheus.metadata[0].name

        container {
          name  = "prometheus"
          image = "prom/prometheus:v2.45.0"
          args  = [
            "--config.file=/etc/prometheus/prometheus.yml",
            "--storage.tsdb.retention.time=15d",
            "--web.enable-lifecycle"
          ]

          port {
            container_port = 9090
            name           = "http"
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

  # Adiciona timeouts mais longos para lidar com pods pendentes
  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
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