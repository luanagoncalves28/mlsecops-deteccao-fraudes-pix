############################################################
# iac/providers.tf - Corrigido para evitar dependência circular
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

# KUBERNETES - Configurado para aceitar erros durante inicialização
provider "kubernetes" {
  host                   = try("https://${module.gke.host}", "dummy")
  cluster_ca_certificate = try(base64decode(module.gke.cluster_ca_certificate), "")
  token                  = data.google_client_config.default.access_token
  
  # Ignorar erros durante a fase de inicialização
  ignore_annotations      = true
  ignore_labels           = true
}

# GRAFANA - Desativado temporariamente até estar pronto
# provider "grafana" {
#   url  = "http://${var.grafana_lb_ip}"
#   auth = "admin:${var.grafana_admin_password}"
# } 