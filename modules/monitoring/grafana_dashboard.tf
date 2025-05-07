# Renomeie o arquivo para modules/monitoring/grafana_dashboard.tf.disabled
# Ou comente o conteúdo:

/*
resource "grafana_dashboard" "mlsec_observability" {
  config_json = file("${path.module}/dashboards/mlsec_observability.json")
}
*/