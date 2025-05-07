resource "kubernetes_config_map" "prometheus_config" {
  metadata {
    name      = "prometheus-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "prometheus.yml" = <<YAML
global:
  scrape_interval: 15s
  evaluation_interval: 15s

# Regras de alerta para monitorar componentes críticos
rule_files:
  - "/etc/prometheus/alert_rules.yml"

scrape_configs:
  # Monitorar o próprio Prometheus
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']
    
  # Métricas específicas de ML 
  - job_name: ml_metrics_exporter
    static_configs:
      - targets: ['ml-metrics-exporter:8080']
    
  # Descoberta automática de serviços Kubernetes anotados
  - job_name: kubernetes-pods
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
        regex: (.+):(\\d+);(\\d+)
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
YAML

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