##########################################################
# FILE: variables.tf
# MODULE: vpc
# DESCRIPTION:
# Variáveis para o módulo de VPC e rede
##########################################################

variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
}

variable "region" {
  description = "Região onde será criada a subnet"
  type        = string
}
