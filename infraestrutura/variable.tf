############################################################
# FILE: variables.tf
# PROJECT: mlsecpix-infra
# DESCRIPTION:
# Define as variáveis globais do projeto, seguindo
# princípios de Clean Code e MLSecOps.
# Em produção, recomenda-se armazenar valores sensíveis
# em Vault/Secret Manager e não em plaintext.
#
# Comentários contextuais para demonstrar expertise em
# segurança, compliance e boas práticas de organização.
############################################################

############################################################
# VARIÁVEIS GCP
# - O arquivo terraform.tfvars ou as variáveis no Terraform
# Cloud irão suprir estes valores, sem expor segredos
# diretamente no código. Em ambiente real, atentar para
# versionamento e masking de logs.
############################################################

variable "gcp_project_id" {
  type        = string
  description = "ID do projeto GCP para provisionar recursos."
}

variable "gcp_region" {
  type        = string
  description = "Região padrão para os recursos GCP (ex.: southamerica-east1)."
  default     = "southamerica-east1"
}

variable "gcp_zone" {
  type        = string
  description = "Zona padrão GCP (ex.: southamerica-east1-b)."
  default     = "southamerica-east1-b"
}

############################################################
# CREDENCIAIS GCP
# - Em produção, usar base64decode(var.gcp_sa_credentials_b64)
# ou conectar via IAM de conta de serviço gerenciado.
############################################################

variable "gcp_sa_credentials_b64" {
  type        = string
  description = "Credenciais da conta de serviço GCP em formato base64."
  sensitive   = true
}

############################################################
# VARIÁVEIS DATABRICKS
# - Token de acesso e host do workspace, marcados como
# sensíveis para evitar exposição em logs.
# - Em um projeto real, poderia usar Terraform Cloud
# com var. sensíveis ou cofre de segredos.
############################################################

variable "databricks_host" {
  type        = string
  description = "URL do workspace Databricks (ex.: https://dbc-1234.cloud.databricks.com)."
}

variable "databricks_token" {
  type        = string
  description = "Token de acesso Databricks."
  sensitive   = true
}

############################################################
# VARIÁVEIS GITHUB
# - Se o Terraform for gerenciar algo no GitHub (webhooks,
# repositórios), definimos esse token. Marcar como sensitive.
############################################################

variable "github_token" {
  type        = string
  description = "Personal Access Token do GitHub, com permissões adequadas."
  sensitive   = true
}

############################################################
# EXEMPLO DE OUTRAS VARIÁVEIS
# - Caso necessite diferenciar ambientes (ex.: dev, prod),
# declare abaixo. Ou use locals se for fixo.
############################################################

variable "environment" {
  type        = string
  description = "Nome do ambiente (dev, staging, prod)."
  default     = "dev"
}
