############################################################
# ✅ ARQUIVO A SER MODIFICADO: iac/providers.tf
# Objetivo: incluir provider correto para o Grafana (grafana/grafana)
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

############################################################
# GOOGLE – usa o JSON codificado em base64
############################################################
provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
  credentials = base64decode(var.gcp_credentials_b64)
}

data "google_client_config" "default" {}

############################################################
# KUBERNETES – configuração específica do cluster GKE
############################################################
provider "kubernetes" {
  host                   = "https://${module.gke.host}"
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

provider "kubernetes" {
  alias                  = "gke"
  host                   = "https://${module.gke.host}"
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

############################################################
# GRAFANA – integração via API REST para dashboards
############################################################
provider "grafana" {
  url = "http://grafana.monitoring.svc.cluster.local" # DNS interno do cluster
  auth = {
    basic_auth = {
      username = "admin"
      password = var.grafana_admin_password
    }
  }
}