resource "kubernetes_config_map" "prometheus_ml_alerts" {
  metadata {
    name      = "prometheus-ml-alerts"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "ml_alerts.yml" = <<EOF
groups:
- name: MLOpsAlerts
  rules:
  - alert: ModelDriftCritical
    expr: model_drift_score > 0.2
    for: 30m
    labels:
      severity: critical
      domain: mlops
    annotations:
      summary: "Drift crítico detectado no modelo"
      description: "Drift superior a 20% detectado nas últimas 30 minutos"
      
  - alert: ModelPerformanceDegradation
    expr: model_f1_score < 0.8
    for: 1h
    labels:
      severity: warning
      domain: mlops
    annotations:
      summary: "Degradação de performance do modelo"
      description: "O F1-score caiu abaixo de 0.8"
      
  - alert: ModelFreshnessCritical
    expr: model_freshness_days > 30
    for: 1d
    labels:
      severity: warning
      domain: mlops
    annotations:
      summary: "Modelo desatualizado"
      description: "O modelo está em produção há mais de 30 dias sem atualização"
      
  - alert: AdversarialAttackSuspected
    expr: sum(rate(adversarial_attempts_total[15m])) > 5
    for: 5m
    labels:
      severity: critical
      domain: mlsecops
    annotations:
      summary: "Possível ataque adversarial em andamento"
      description: "Detectadas múltiplas tentativas de ataque nos últimos 15 minutos"
EOF
  }
}