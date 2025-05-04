# Caminho: modules/monitoring/grafana_dashboard.tf

resource "grafana_dashboard" "mlsec_observability" {
  config_json = file("${path.module}/dashboards/mlsec_observability.json")
}