terraform {
  required_version = ">= 1.4"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.27"
    }
  }
}

############################################################
# GOOGLE – usa o JSON passado na variável gcp_credentials
############################################################
provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  credentials = var.gcp_credentials
}

# Pega o access‑token da conta que o provider google está usando
data "google_client_config" "default" {}

############################################################
# KUBERNETES – configuração específica do cluster GKE
# (note o alias "gke")
############################################################
provider "kubernetes" {
  alias                  = "gke"

  host                   = module.gke.host
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}