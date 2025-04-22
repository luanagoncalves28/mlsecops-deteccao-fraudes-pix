##########################################################
# Variáveis globais do projeto
##########################################################

variable "gcp_project_id" {
  description = "ID do projeto GCP onde todos os recursos serão criados."
  type        = string
}

variable "gcp_region" {
  description = "Região padrão para recursos GCP (ex.: buckets, GKE, NAT)."
  type        = string
}

variable "gcp_zone" {
  description = "Zona padrão para recursos zonais (VMs, discos, etc.)."
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (dev, staging, prod, …) — usado em tags, nomes de buckets, etc."
  type        = string
}

# Aqui recebemos o JSON puro da service account como _string_
variable "gcp_credentials" {
  description = "JSON da Service Account (usando heredoc para preservar quebras de linha)."
  type        = string
  sensitive   = true
}

# Se você usa Databricks, declare; caso contrário remova estas duas
variable "databricks_host" {
  description = "URL do workspace Databricks onde os jobs/notebooks serão provisionados."
  type        = string
}

variable "databricks_token" {
  description = "Token de acesso ao Databricks."
  type        = string
  sensitive   = true
}