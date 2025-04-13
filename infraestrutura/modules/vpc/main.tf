############################################################
# FILE: main.tf
# FOLDER: mlsecpix-infra/modules/vpc/
# DESCRIPTION:
#   Este arquivo cria os recursos de rede GCP necessários para
#   o projeto MLSecPix. Ele provisiona uma VPC personalizada e
#   uma sub-rede associada, utilizando as variáveis definidas em
#   variable.tf. Dessa forma, o módulo VPC fica modularizado,
#   facilitando a manutenção e a auditoria (com fluxo de logs habilitado)
#   em conformidade com as melhores práticas de Clean Code e MLSecOps.
############################################################

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
    enable               = var.enable_flow_logs
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
