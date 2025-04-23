############################################################
# Saídas necessárias para que outros módulos (ex.: k8s) 
# possam falar com o cluster Autopilot
############################################################
output "host" {
  description = "Endpoint da API server do GKE"
  value       = google_container_cluster.autopilot.endpoint
}

output "cluster_ca_certificate" {
  description = "CA pública do cluster em Base64"
  value       = google_container_cluster.autopilot.master_auth[0].cluster_ca_certificate
}

output "name" {
  description = "Nome do cluster GKE"
  value       = google_container_cluster.autopilot.name
}