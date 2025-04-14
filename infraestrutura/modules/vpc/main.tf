##########################################################
# FILE: main.tf
# MODULE: vpc
# DESCRIPTION:
# Cria a VPC e subnets para o projeto MLSecPix
##########################################################

resource "google_compute_network" "mlsecpix_vpc" {
  name                    = "mlsecpix-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "mlsecpix_subnet" {
  name          = "mlsecpix-subnet"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.mlsecpix_vpc.self_link
  ip_cidr_range = "10.0.0.0/16"

  secondary_ip_range {
    range_name    = "mlsecpix-pod-range"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "mlsecpix-service-range"
    ip_cidr_range = "10.2.0.0/16"
  }

  # Habilitar logs de fluxo para auditoria de rede
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Firewall para permitir acesso SSH e Health checks
resource "google_compute_firewall" "allow_ssh_and_health" {
  name    = "mlsecpix-allow-ssh-health"
  network = google_compute_network.mlsecpix_vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]
  target_tags   = ["mlsecpix"]
}

# Cloud NAT para permitir que nodes sem IP público acessem a internet
resource "google_compute_router" "mlsecpix_router" {
  name    = "mlsecpix-router"
  region  = var.region
  network = google_compute_network.mlsecpix_vpc.self_link
  project = var.project_id
}

resource "google_compute_router_nat" "mlsecpix_nat" {
  name                               = "mlsecpix-nat"
  router                             = google_compute_router.mlsecpix_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project                            = var.project_id

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
