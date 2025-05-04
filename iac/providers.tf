############################################################
# iac/providers.tf  – versão enxuta, 1 provider kubernetes
############################################################
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
    grafana = {
      source  = "grafana/grafana"
      version = ">= 1.40.0"
    }
  }
}

# GOOGLE
provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
  credentials = base64decode(var.gcp_credentials_b64)
}

data "google_client_config" "default" {}

# KUBERNETES – **apenas um** cluster (autopilot)
provider "kubernetes" {
  host                   = "https://${module.gke.host}"
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

# GRAFANA – usa auth como string
provider "grafana" {
  url  = "http://${var.grafana_lb_ip}"
  auth = "admin:${var.grafana_admin_password}"
}