############################################################
# FILE: variables.tf
# FOLDER: mlsecpix-infra/modules/vpc/
# DESCRIPTION:
#   Declara todas as variáveis necessárias para provisionar
#   a rede VPC do projeto MLSecPix (fictício). Antes, 
#   no main.tf do módulo, esses blocos de variáveis 
#   estavam inline; agora, separamos em variables.tf 
#   para seguir ainda mais as boas práticas de Clean Code.
#
#   Em um ambiente real, usaríamos esse arquivo para
#   manter a clareza de quais parâmetros o módulo VPC 
#   espera, reduzindo a chance de erros e mantendo 
#   cada arquivo focado em uma responsabilidade.
############################################################

############################################################
# GCP PROJECT
#   Identifica o projeto onde os recursos de rede
#   (VPC, sub-rede, firewall) serão criados.
############################################################
variable "project_id" {
  type        = string
  description = "ID do projeto GCP onde a VPC será criada."
}

############################################################
# REGIÃO GCP
#   Região padrão a ser utilizada para sub-redes e 
#   recursos regionais (ex.: 'southamerica-east1').
############################################################
variable "region" {
  type        = string
  description = "Região principal do GCP."
}

############################################################
# NOME DA VPC
#   Por padrão, definimos 'mlsecpix-vpc', mas pode ser 
#   sobrescrito quando o módulo for chamado.
############################################################
variable "vpc_name" {
  type        = string
  description = "Nome desejado para a rede VPC."
  default     = "mlsecpix-vpc"
}

############################################################
# NOME DA SUB-REDE
#   Sub-rede principal usada para rodar workloads
#   (ex.: GKE, Databricks no caso de peering, etc.).
############################################################
variable "subnet_name" {
  type        = string
  description = "Nome desejado para a sub-rede."
  default     = "mlsecpix-subnet"
}

############################################################
# CIDR DA SUB-REDE
#   Intervalo de IPs disponível (ex.: 10.0.0.0/16).
############################################################
variable "cidr_subnet" {
  type        = string
  description = "CIDR da sub-rede (ex.: 10.0.0.0/16)."
  default     = "10.0.0.0/16"
}

############################################################
# FLOW LOGS
#   Indica se deve habilitar Flow Logs na sub-rede.
#   Flow Logs geram metadados de tráfego para auditoria,
#   crucial em MLSecOps e compliance (BCB nº 403).
############################################################
variable "enable_flow_logs" {
  type        = bool
  description = "Habilitar ou não Flow Logs para auditoria."
  default     = true
}
