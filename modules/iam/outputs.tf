output "dbx_jobs_sa_email" {
  description = "E‑mail da Service Account usada pelos jobs do Databricks"
  value       = google_service_account.dbx_jobs.email
}

output "gke_workload_sa_email" {
  value       = google_service_account.gke_workload.email
}