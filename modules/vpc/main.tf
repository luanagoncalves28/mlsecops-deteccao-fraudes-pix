resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  project                 = var.project_id
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.network_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

# Firewall básico: SSH + Health‑checks
resource "google_compute_firewall" "allow_ssh_health" {
  name    = "${var.network_name}-allow-ssh-health"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = [
    "35.191.0.0/16",  # Google LB health checks
    "130.211.0.0/22",
    "0.0.0.0/0"       # SSH (ajuste depois se quiser restringir)
  ]

  target_tags = [var.network_name]
}

# Router + Cloud NAT para saídas públicas sem IP externo nas VMs
resource "google_compute_router" "router" {
  name    = "${var.network_name}-router"
  network = google_compute_network.vpc.id
  region  = var.region
  project = var.project_id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}