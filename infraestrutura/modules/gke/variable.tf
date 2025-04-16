##########################################################
# FILE: variables.tf
# MODULE: gke
# DESCRIPTION:
# Define variáveis para configuração do cluster GKE
# para o projeto MLSecPix.
##########################################################

variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
}

variable "region" {
  description = "Região do GCP para provisionar o cluster"
  type        = string
}

variable "vpc_self_link" {
  description = "Self link da VPC onde o cluster será provisionado"
  type        = string
}

variable "subnet_self_link" {
  description = "Self link da subnet onde o cluster será provisionado"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "node_count" {
  description = "Número de nós por zona"
  type        = number
  default     = 1
}

variable "min_nodes" {
  description = "Número mínimo de nós para autoscaling"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Número máximo de nós para autoscaling"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "Tipo de máquina para os nós do GKE"
  type        = string
  default     = "e2-medium"
}

variable "labels" {
  description = "Labels a serem aplicados ao cluster"
  type        = map(string)
  default     = {}
}
