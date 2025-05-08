resource "kubernetes_config_map" "ml_metrics_exporter_config" {
  metadata {
    name      = "ml-metrics-exporter-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "app.py" = file("${path.module}/ml_metrics_exporter/app.py")
  }
}