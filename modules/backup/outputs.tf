output "backup_bucket_name" {
  description = "Nome do bucket de backups"
  value       = google_storage_bucket.backup_bucket.name
}

output "backup_function_url" {
  description = "URL de trigger da Cloud Function de backup"
  value       = google_cloudfunctions_function.backup_function.https_trigger_url
}

output "scheduler_job_name" {
  description = "Nome do job do Cloud Scheduler"
  value       = google_cloud_scheduler_job.backup_scheduler.name
}