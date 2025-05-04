############################################################
# Variáveis globais do projeto
############################################################
variable "gcp_project_id" {
  description = "ID do projeto GCP onde todos os recursos serão criados"
  type        = string
}

variable "gcp_region" {
  description = "Região padrão para recursos GCP (ex.: buckets, GKE, NAT)"
  type        = string
}

variable "gcp_zone" {
  description = "Zona padrão para recursos zonais (VMs, discos, etc.)"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (dev, staging, prod, …) — usado em tags, nomes de buckets, etc."
  type        = string
}

# Credenciais como string base64
variable "gcp_credentials_b64" {
  description = "JSON da Service Account em formato base64, sem quebras de linha"
  type        = string
  sensitive   = true
}

# Variáveis para Databricks
variable "databricks_host" {
  description = "URL do workspace Databricks onde os jobs/notebooks serão provisionados"
  type        = string
}

variable "databricks_token" {
  description = "Token de acesso ao Databricks"
  type        = string
  sensitive   = true
}

########################################################################
# Variável usada no provider grafana
########################################################################
variable "grafana_admin_password" {
  description = "Senha de admin para autenticação básica no Grafana"
  type        = string
  sensitive   = true
}