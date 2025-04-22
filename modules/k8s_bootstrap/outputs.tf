output "namespace"   { value = kubernetes_namespace.ml.metadata[0].name }
output "workload_sa" { value = google_service_account.ml_workload.email }