# Configuração principal para ambiente de desenvolvimento
# Autor: Luana Gonçalves
# Data: Abril 2025
terraform {
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

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Habilitação de serviços necessários
resource "google_project_service" "gcp_services" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "storage.googleapis.com",
    "pubsub.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudtrace.googleapis.com",
    "artifactregistry.googleapis.com",
    "aiplatform.googleapis.com",
    "bigquery.googleapis.com"
  ])
  
  project                    = var.project_id
  service                    = each.key
  disable_dependent_services = false
  disable_on_destroy         = false

  timeouts {
    create = "30m"
    update = "40m"
  }
}

module "rede" {
  source = "../../modulos/rede"
  
  project_id  = var.project_id
  region      = var.region
  environment = var.environment
  labels      = var.labels
}

module "gke" {
  source = "../../modulos/gke"
  
  project_id       = var.project_id
  region           = var.region  # Este parâmetro estava faltando
  zone             = var.zone
  environment      = var.environment
  labels           = var.labels
  network_name     = "mlsecops-vpc-dev"  # Este parâmetro estava faltando
  subnetwork_name  = "mlsecops-subnet-dev"
  machine_type     = var.machine_type
  gke_num_nodes    = var.min_node_count  # Usando min_node_count como valor para gke_num_nodes
  
  # Dependência do módulo de rede
  depends_on = [module.rede, google_project_service.gcp_services]
}

module "armazenamento" {
  source = "../../modulos/armazenamento"
  
  project_id  = var.project_id
  region      = var.region
  environment = var.environment
  labels      = var.labels
  
  depends_on = [google_project_service.gcp_services]
}