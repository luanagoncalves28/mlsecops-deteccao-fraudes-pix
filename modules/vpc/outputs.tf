output "network_self_link" {
  description = "Self‑link da VPC"
  value       = google_compute_network.vpc.self_link
}

output "subnet_self_link" {
  description = "Self‑link da subnet"
  value       = google_compute_subnetwork.subnet.self_link
}