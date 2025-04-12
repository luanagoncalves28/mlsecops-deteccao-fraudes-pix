############################################################
# FILE: variables.tf
# PROJECT: mlsecpix-infra
# DESCRIPTION:
#   Define as variáveis globais do projeto MLSecPix.
#   São utilizadas para configurar o provisionamento dos 
#   recursos (GCP, Databricks, GitHub) de forma segura e 
#   modular, atendendo aos requisitos das fases 1, 2 e 3 
#   (Análise Regulatória, Tradução para Requisitos Técnicos 
#   e Design Arquitetural). Segue os princípios de Clean Code, 
#   evitando hardcode e "strings mágicas", e garantindo a 
#   rastreabilidade e conformidade (ex.: Resolução BCB nº 403).
############################################################

############################################################
# GCP CONFIGURATION
############################################################
variable "gcp_project_id" {
  type        = string
  description = "ID do projeto GCP onde os recursos serão criados."
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
# CREDENCIAL DE CONTA DE SERVIÇO GCP
#   Para não expor o arquivo JSON em repositórios ou 
#   logs, converta o JSON da conta de serviço para uma 
#   string base64 e armazene nessa variável.
############################################################
variable "gcp_sa_credentials_b64" {
  type        = string
  description = "Chave de conta de serviço GCP convertida para base64."
  sensitive   = true
}

############################################################
# DATABRICKS CONFIGURATION
############################################################
variable "databricks_host" {
  type        = string
  description = "URL do workspace Databricks (ex.: https://dbc-7a058f2d-3d4b.cloud.databricks.com)."
}

variable "databricks_token" {
  type        = string
  description = "Token de acesso Databricks."
  sensitive   = true
}

############################################################
# GITHUB CONFIGURATION
############################################################
variable "github_token" {
  type        = string
  description = "Personal Access Token do GitHub, com permissões adequadas."
  sensitive   = true
}

############################################################
# AMBIENTE
############################################################
variable "environment" {
  type        = string
  description = "Nome do ambiente (dev, staging, prod)."
  default     = "dev"
}

# Outras variáveis necessárias para módulos específicos
# podem ser adicionadas aqui ou em arquivos de variáveis
# separados dentro dos módulos.
