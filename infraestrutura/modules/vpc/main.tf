##########################################################
# FILE: main.tf
# FOLDER: mlsecpix-infra/modules/vpc/
# DESCRIPTION:
# Este arquivo cria os recursos de rede GCP necessários para
# o projeto MLSecPix. Ele provisiona uma VPC personalizada e
# uma sub-rede associada, utilizando as variáveis definidas em
# variable.tf. Dessa forma, o módulo VPC fica modularizado,
# facilitando a manutenção e a auditoria (com fluxo de logs habilitado)
# em conformidade com as melhores práticas de Clean Code e MLSecOps.
##########################################################

# Cria a VPC personalizada sem sub-redes automáticas.
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false

  # Labels para controle, auditoria e rastreabilidade
  labels = {
    environment = var.environment
    project     = "mlsecpix"
  }
}

# Cria a sub-rede associada à VPC criada acima.
resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.cidr_subnet
  region        = var.region
  project       = var.project_id
  network       = google_compute_network.vpc.id

  # Habilita Flow Logs para garantir auditoria e conformidade
  # regulatória (por exemplo, requisitos da Resolução BCB nº 403).
  log_config {
    enable = var.enable_flow_logs
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling = 0.5
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Firewall para permitir acesso SSH e Health checks
resource "google_compute_firewall" "allow_ssh_and_health" {
  name    = "mlsecpix-allow-ssh-health"
  network = google_compute_network.vpc.name
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
  network = google_compute_network.vpc.self_link
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
