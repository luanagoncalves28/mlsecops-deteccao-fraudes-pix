locals {
  prefix = "mlsecpix-${var.environment}"
}

# -------- Service Account p/ Databricks jobs ---------------
resource "google_service_account" "dbx_jobs" {
  account_id   = "${local.prefix}-dbx-jobs"
  display_name = "Databricks Jobs SA"
  project      = var.project_id
}

# -------- Service Account p/ GKE workloads -----------------
resource "google_service_account" "gke_workload" {
  account_id   = "${local.prefix}-gke-wl"
  display_name = "GKE Workload SA"
  project      = var.project_id
}

# -------- Papéis (principle of least privilege) ------------
# Acesso de leitura/escrita nos buckets de dados
resource "google_project_iam_member" "dbx_jobs_storage_rw" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.dbx_jobs.email}"
}

resource "google_project_iam_member" "gke_workload_storage_ro" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.gke_workload.email}"
}

# Logging writer (para auditoria)
resource "google_project_iam_member" "logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_workload.email}"
}