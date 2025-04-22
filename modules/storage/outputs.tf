output "bucket_names" {
  value = [
    for b in concat(
      values(google_storage_bucket.tiers)[*].name,
      google_storage_bucket.audit_hot.name,
      google_storage_bucket.audit_cold.name
    ) : b
  ]
}