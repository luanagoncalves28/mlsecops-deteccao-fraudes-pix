###############################################################################
# outputs.tf  – Storage module
###############################################################################

# Lista com TODOS os buckets criados (tiers + audit)
output "bucket_names" {
  description = "Nomes dos buckets de dados (bronze/silver/gold) e auditoria."
  value = concat(
    [ for b in google_storage_bucket.tier : b.name ],           # lista
    [ google_storage_bucket.audit_hot.name ],                   # string → lista
    [ google_storage_bucket.audit_cold.name ]                   # string → lista
  )
}

# URL do bucket‑canary criado no root
output "canary_bucket_url" {
  description = "URL do bucket tf_canary criado fora do módulo – root."
  value       = google_storage_bucket.tf_canary.url
}

# EOF
