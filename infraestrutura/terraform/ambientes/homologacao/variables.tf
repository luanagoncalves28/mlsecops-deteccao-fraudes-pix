# Ambiente de Homologação - variables.tf
# Autor: Luana Gonçalves
# Data: Abril 2025

variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
}

variable "region" {
  description = "Região principal para recursos do GCP"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zona principal para recursos do GCP"
  type        = string
  default     = "us-central1-a"
}

variable "environment" {
  description = "Ambiente (dev, homologacao, producao)"
  type        = string
  default     = "homologacao"
}

variable "labels" {
  description = "Labels a serem aplicados aos recursos"
  type        = map(string)
  default     = {}
}