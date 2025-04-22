###############################################################################
# iac/outputs.tf  – outputs do root
###############################################################################

output "canary_bucket_url" {
  description = "URL do bucket canary criado para validação."
  value       = google_storage_bucket.tf_canary.url
}
