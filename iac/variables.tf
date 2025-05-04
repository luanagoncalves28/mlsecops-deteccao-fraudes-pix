###############################################################################
# VARIÁVEIS GLOBAIS
###############################################################################
variable "gcp_project_id" {
  description = "ID do projeto GCP onde todos os recursos serão criados"
  type        = string
}

variable "gcp_region" {
  description = "Região padrão para recursos GCP"
  type        = string
}

variable "gcp_zone" {
  description = "Zona padrão para recursos zonais"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (dev, staging, prod, …)"
  type        = string
}

variable "gcp_credentials_b64" {
  description = "JSON da Service Account em base64"
  type        = string
  sensitive   = true
}

#########################
# Databricks
#########################
variable "databricks_host" {
  description = "URL do workspace Databricks"
  type        = string
}

variable "databricks_token" {
  description = "Token de acesso ao Databricks"
  type        = string
  sensitive   = true
}

#########################
# Grafana
#########################
variable "grafana_admin_password" {
  description = "Senha do admin do Grafana"
  type        = string
  sensitive   = true
}

# IP (ou hostname) público atribuído pelo Service LoadBalancer do Grafana
variable "grafana_lb_ip" {
  description = "IP ou hostname externo do Service LoadBalancer do Grafana"
  type        = string
}