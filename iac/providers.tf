###############################################################################
# PROVEDORES – CAMADA ROOT
###############################################################################

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

#########################
# GOOGLE
#########################
provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
  credentials = base64decode(var.gcp_credentials_b64)
}

data "google_client_config" "default" {}

#########################
# KUBERNETES (cluster GKE)
#########################
provider "kubernetes" {
  host                   = "https://${module.gke.host}"
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

#########################
# GRAFANA
# – Usa o endereço público/NAT do Service LoadBalancer criado no módulo.
#########################
provider "grafana" {
  url  = "http://${var.grafana_lb_ip}:80"
  auth = "admin:${var.grafana_admin_password}"
}