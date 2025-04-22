# Namespace onde ficarão os workloads de serving
resource "kubernetes_namespace" "ml" {
  metadata {
    name = local.ns_ml
  }
}

# Service Account (GCP) que o pod usará via Workload Identity
resource "google_service_account" "ml_workload" {
  account_id   = "gke-ml-workload"
  display_name = "Workload Identity para pods de ML serving"
}

# Vincula a SA GCP à identidade do ServiceAccount padrão do namespace
resource "google_service_account_iam_member" "wl_bind" {
  service_account_id = google_service_account.ml_workload.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${local.ns_ml}/default]"
}

# (opcional) se quiser quotas, RBAC etc., eles entram aqui depois