# Namespace para o monitoramento
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.prometheus_namespace
    labels = merge(var.labels, {
      "app.kubernetes.io/component" = "monitoring"
      "app.kubernetes.io/part-of"   = "mlsecops"
      "environment"                 = var.environment
    })
  }
}