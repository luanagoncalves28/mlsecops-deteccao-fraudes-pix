##########################################################
# FILE: outputs.tf
# MODULE: gke
# DESCRIPTION:
# Exporta informações relevantes do cluster GKE criado
##########################################################

output "cluster_name" {
  description = "Nome do cluster GKE"
  value       = google_container_cluster.mlsecpix_cluster.name
}

output "endpoint" {
  description = "Endpoint do cluster GKE"
  value       = google_container_cluster.mlsecpix_cluster.endpoint
}

output "master_version" {
  description = "Versão do Kubernetes no cluster"
  value       = google_container_cluster.mlsecpix_cluster.master_version
}

output "cluster_ca_certificate" {
  description = "Certificado CA do cluster"
  value       = google_container_cluster.mlsecpix_cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}
