resource "kubernetes_config_map" "prometheus_regulatory_alerts" {
  metadata {
    name      = "prometheus-regulatory-alerts"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "regulatory_alerts.yml" = <<-EOF
      groups:
      - name: RegulatoryCompliance
        rules:
        - alert: HighFalsePositiveRate
          expr: (prediction_fraud_rate / (model_precision + 0.001)) > 0.05
          for: 30m
          labels:
            severity: critical
            domain: regulatory
          annotations:
            summary: "Alta taxa de falsos positivos"
            description: "Taxa de falsos positivos acima do limite regulatório (5%) nos últimos 30 minutos"
            compliance_ref: "BCB 403, Art. 91"
            runbook_url: "https://github.com/org/mlsecops-deteccao-fraudes-pix/docs/runbooks/high_false_positive.md"
            
        - alert: ModelExplainabilityLow
          expr: model_explainability_score{model_version="1.0"} < 0.9 or absent(model_explainability_score{model_version="1.0"})
          for: 60m
          labels:
            severity: warning
            domain: regulatory
          annotations:
            summary: "Baixa explicabilidade do modelo"
            description: "Modelo com score de explicabilidade abaixo do mínimo regulatório (90%) por mais de 1 hora"
            compliance_ref: "BCB 403, Art. 94"
            runbook_url: "https://github.com/org/mlsecops-deteccao-fraudes-pix/docs/runbooks/low_explainability.md"
            
        - alert: DataRetentionNonCompliant
          expr: data_retention_compliance < 1 or absent(data_retention_compliance)
          for: 24h
          labels:
            severity: critical
            domain: regulatory
          annotations:
            summary: "Não conformidade na retenção de dados"
            description: "Verificada não conformidade nos períodos de retenção de dados por mais de 24 horas"
            compliance_ref: "BCB 403, Art. 89"
            runbook_url: "https://github.com/org/mlsecops-deteccao-fraudes-pix/docs/runbooks/data_retention.md"
            
        - alert: DriftDetected
          expr: model_drift_score > 0.1
          for: 60m
          labels:
            severity: warning
            domain: regulatory
          annotations:
            summary: "Drift significativo no modelo"
            description: "Drift detectado acima do limiar aceitável (10%) por mais de 1 hora. Retreinamento pode ser necessário."
            compliance_ref: "BCB 403, Art. 91"
            runbook_url: "https://github.com/org/mlsecops-deteccao-fraudes-pix/docs/runbooks/model_drift.md"
            
        - alert: DictIntegrationFailure
          expr: dict_integration_status == 0
          for: 15m
          labels:
            severity: critical
            domain: regulatory
          annotations:
            summary: "Falha na integração com DICT"
            description: "Integração com DICT está inoperante por mais de 15 minutos, comprometendo a validação de transações"
            compliance_ref: "BCB 403, Art. 89, Parágrafo Único"
            runbook_url: "https://github.com/org/mlsecops-deteccao-fraudes-pix/docs/runbooks/dict_failure.md"
        
        - alert: AuditLoggingIncomplete
          expr: audit_log_integrity < 1 or absent(audit_log_integrity)
          for: 30m
          labels:
            severity: critical
            domain: regulatory
          annotations:
            summary: "Registros de auditoria incompletos"
            description: "Sistema de log de auditoria comprometido, afetando a rastreabilidade exigida por regulamentação"
            compliance_ref: "BCB 403, Art. 93"
            runbook_url: "https://github.com/org/mlsecops-deteccao-fraudes-pix/docs/runbooks/audit_logs.md"
        
        - alert: ModelResponseTimeSlow
          expr: histogram_quantile(0.95, sum(rate(inference_latency_seconds_bucket[5m])) by (le)) > 0.2
          for: 15m
          labels:
            severity: warning
            domain: regulatory
          annotations:
            summary: "Tempo de resposta do modelo acima do limite"
            description: "Latência P95 do modelo acima do limite regulatório de 200ms por mais de 15 minutos"
            compliance_ref: "BCB 403, Art. 89"
            runbook_url: "https://github.com/org/mlsecops-deteccao-fraudes-pix/docs/runbooks/latency.md"
      EOF
  }
}