variable "project_id" {
  description = "ID do projeto GCP onde os repositórios serão criados"
  type        = string
}

variable "region" {
  description = "Região do GCP onde os repositórios serão criados"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "repository_id" {
  description = "ID do repositório Artifact Registry"
  type        = string
  default     = "mlsecpix-images"
}

variable "labels" {
  description = "Labels a serem aplicados nos recursos"
  type        = map(string)
  default     = {}
}