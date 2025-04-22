############################################################
# Variáveis globais do projeto
############################################################
variable "gcp_project_id" {
  description = "ID do projeto GCP onde tudo será criado"
  type        = string
}

variable "gcp_region" {
  description = "Região padrão (GKE, Storage, etc.)"
  type        = string
}

variable "environment" {
  description = "Ambiente de implantação (dev, prod, …)"
  type        = string
}

variable "gcp_credentials" {
  description = "JSON da Service Account (com quebras de linha \\n no campo private_key)"
  type        = string
  sensitive   = true
}