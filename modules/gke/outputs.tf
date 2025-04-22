# modules/gke/outputs.tf
output "endpoint" {
  value = google_container_cluster.autopilot.endpoint
}

output "cluster_ca_certificate" {
  value     = google_container_cluster.autopilot.master_auth.0.cluster_ca_certificate
  sensitive = true
}