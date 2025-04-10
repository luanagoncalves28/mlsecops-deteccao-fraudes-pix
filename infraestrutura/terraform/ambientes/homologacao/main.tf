# Ambiente de Homologação - main.tf
# Autor: Luana Gonçalves
# Data: Abril 2025

terraform {
  required_version = ">= 1.5.0"
  
  backend "local" {
    path = "terraform.tfstate"
  }
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.11.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.11.0"
    }
  }
}

# Variáveis locais
locals {
  project_id  = var.project_id
  region      = var.region
  zone        = var.zone
  environment = var.environment
  labels      = var.labels
}

# Configurações dos provedores
provider "google" {
  project = local.project_id
  region  = local.region
  zone    = local.zone
}

provider "google-beta" {
  project = local.project_id
  region  = local.region
  zone    = local.zone
}

# Ativar APIs necessárias
resource "google_project_service" "gcp_services" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudtrace.googleapis.com",
    "aiplatform.googleapis.com",
    "bigquery.googleapis.com",
    "storage.googleapis.com",
    "pubsub.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com"
  ])
  
  project = local.project_id
  service = each.key
  
  disable_dependent_services = false
  disable_on_destroy         = false
  
  timeouts {
    create = "30m"
    update = "40m"
  }
}

# Módulo de rede
module "rede" {
  source      = "../../../modulos/rede"
  project_id  = local.project_id
  region      = local.region
  environment = local.environment
  labels      = local.labels
  
  depends_on = [google_project_service.gcp_services]
}

# Módulo de armazenamento
module "armazenamento" {
  source      = "../../../modulos/armazenamento"
  project_id  = local.project_id
  region      = local.region
  environment = local.environment
  labels      = local.labels
  
  depends_on = [google_project_service.gcp_services]
}

# Módulo GKE
module "gke" {
  source          = "../../../modulos/gke"
  project_id      = local.project_id
  region          = local.region
  zone            = local.zone
  environment     = local.environment
  labels          = local.labels
  network_name    = module.rede.vpc_name
  subnetwork_name = module.rede.subnet_name
  gke_num_nodes   = 2
  machine_type    = "e2-standard-2"
  
  depends_on = [
    google_project_service.gcp_services,
    module.rede
  ]
}