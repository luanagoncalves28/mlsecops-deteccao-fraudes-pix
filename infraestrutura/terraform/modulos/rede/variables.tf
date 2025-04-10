# Módulo de Rede - variables.tf
# Autor: Luana Gonçalves
# Data: Abril 2025

variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
}

variable "region" {
  description = "Região principal para recursos do GCP"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, homologacao, producao)"
  type        = string
}

variable "labels" {
  description = "Labels a serem aplicados aos recursos"
  type        = map(string)
}