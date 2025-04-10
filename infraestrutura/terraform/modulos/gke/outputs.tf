# Módulo de GKE - outputs.tf
# Autor: Luana Gonçalves
# Data: Abril 2025

output "kubernetes_cluster_name" {
  description = "Nome do cluster GKE"
  value       = google_container_cluster.primary.name
}

output "kubernetes_cluster_endpoint" {
  description = "Endpoint do cluster GKE"
  value       = google_container_cluster.primary.endpoint
}

output "kubernetes_cluster_location" {
  description = "Localização do cluster GKE"
  value       = google_container_cluster.primary.location
}

output "kubernetes_node_pool" {
  description = "Nome do node pool do GKE"
  value       = google_container_node_pool.primary_nodes.name
}