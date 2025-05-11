variable "project_id" {
  description = "ID do projeto GCP onde os backups serão configurados"
  type        = string
}

variable "region" {
  description = "Região do GCP onde os recursos de backup serão criados"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "labels" {
  description = "Labels a serem aplicados nos recursos"
  type        = map(string)
  default     = {}
}