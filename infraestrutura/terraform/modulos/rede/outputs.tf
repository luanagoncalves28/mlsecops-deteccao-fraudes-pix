# Módulo de Rede - outputs.tf
# Autor: Luana Gonçalves
# Data: Abril 2025

output "vpc_id" {
  description = "ID da rede VPC"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "Nome da rede VPC"
  value       = google_compute_network.vpc.name
}

output "subnet_id" {
  description = "ID da subrede"
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_name" {
  description = "Nome da subrede"
  value       = google_compute_subnetwork.subnet.name
}

output "subnet_cidr" {
  description = "CIDR da subrede"
  value       = google_compute_subnetwork.subnet.ip_cidr_range
}

output "pods_cidr" {
  description = "CIDR para pods do GKE"
  value       = google_compute_subnetwork.subnet.secondary_ip_range[0].ip_cidr_range
}

output "services_cidr" {
  description = "CIDR para serviços do GKE"
  value       = google_compute_subnetwork.subnet.secondary_ip_range[1].ip_cidr_range
}