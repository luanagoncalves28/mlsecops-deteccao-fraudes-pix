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

# JSON da service‑account **inteiro** (não base64) —
# será injetado no provider google
variable "gcp_credentials" {
  description = "Credenciais da service‑account em formato JSON"
  type        = string
  sensitive   = true
}