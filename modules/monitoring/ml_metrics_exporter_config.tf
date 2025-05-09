resource "kubernetes_config_map" "ml_metrics_exporter_config" {
  metadata {
    name      = "ml-metrics-exporter-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "ml-metrics-exporter"
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/part-of"    = "mlsecops-monitoring"
    }
  }

  data = {
    "app.py" = file("${path.module}/ml_metrics_exporter/app.py")
    "requirements.txt" = <<-EOF
      flask>=2.0.0
      prometheus-client>=0.16.0
      gunicorn>=20.1.0
    EOF
  }
}