# Módulo de GKE - variables.tf
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

variable "zone" {
  description = "Zona principal para recursos do GCP"
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

variable "network_name" {
  description = "Nome da rede VPC para o cluster GKE"
  type        = string
}

variable "subnetwork_name" {
  description = "Nome da subrede para o cluster GKE"
  type        = string
}

variable "gke_num_nodes" {
  description = "Número de nós no pool padrão do GKE"
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "Tipo de máquina para os nós do GKE"
  type        = string
  default     = "e2-standard-2"
}