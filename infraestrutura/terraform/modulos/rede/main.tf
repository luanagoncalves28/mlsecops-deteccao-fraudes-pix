# Módulo de Rede - main.tf
# Autor: Luana Gonçalves
# Data: Abril 2025

# Rede VPC para o projeto
resource "google_compute_network" "vpc" {
  name                    = "mlsecops-vpc-${var.environment}"
  auto_create_subnetworks = false
  description             = "Rede VPC para projeto MLSecOps de detecção de fraudes Pix"
}

# Subrede para GKE
resource "google_compute_subnetwork" "subnet" {
  name          = "mlsecops-subnet-${var.environment}"
  ip_cidr_range = "10.0.0.0/20"
  network       = google_compute_network.vpc.id
  region        = var.region
  
  # Secundary IP ranges para pods e serviços do GKE
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.16.0.0/14"
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.20.0.0/20"
  }
  
  private_ip_google_access = true
  
  description = "Subrede para o cluster GKE de MLSecOps"
  
  log_config {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Regra de firewall para permitir comunicação interna
resource "google_compute_firewall" "allow_internal" {
  name    = "mlsecops-allow-internal-${var.environment}"
  network = google_compute_network.vpc.name
  
  allow {
    protocol = "icmp"
  }
  
  allow {
    protocol = "tcp"
  }
  
  allow {
    protocol = "udp"
  }
  
  source_ranges = ["10.0.0.0/20", "10.16.0.0/14", "10.20.0.0/20"]
  description   = "Permite comunicação interna entre recursos na VPC"
}

# Regra de firewall para permitir acesso SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "mlsecops-allow-ssh-${var.environment}"
  network = google_compute_network.vpc.name
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["35.235.240.0/20"] # IP ranges para Cloud IAP
  description   = "Permite acesso SSH via Cloud IAP"
}