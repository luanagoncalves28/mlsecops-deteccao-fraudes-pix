###############################################################################
# outputs.tf  – módulo Storage
###############################################################################

# Lista com todos os buckets de dados + auditoria
output "bucket_names" {
  description = "Nomes dos buckets (bronze/silver/gold + audit)."
  value = concat(
    [ for b in values(google_storage_bucket.tiers) : b.name ],   # << aqui plural
    [ google_storage_bucket.audit_hot.name ],
    [ google_storage_bucket.audit_cold.name ]
  )
}

# EOF

output "cloudbuild_logs_bucket_name" {
  description = "Nome do bucket de logs do Cloud Build"
  value       = google_storage_bucket.cloudbuild_logs.name
}
