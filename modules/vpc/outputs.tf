# modules/vpc/outputs.tf
output "network" {
  description = "Self‑link da VPC (para outros módulos)"
  value       = google_compute_network.vpc.self_link
}

output "subnet" {
  description = "Self‑link da sub‑rede padrão"
  value       = google_compute_subnetwork.subnet.self_link
}