variable "project_id" {
  description = "ID do projeto GCP onde o módulo será implantado"
  type        = string
}

variable "region" {
  description = "Região do GCP onde os recursos serão criados"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "Nome do cluster GKE onde o monitoramento será implantado"
  type        = string
}

variable "prometheus_namespace" {
  description = "Namespace para implantação do Prometheus e Grafana"
  type        = string
  default     = "monitoring"
}

variable "grafana_admin_password" {
  description = "Senha do admin do Grafana"
  type        = string
  sensitive   = true
  default     = "MLSecOps@2025" # Padrão para o projeto demonstrativo
}

variable "retention_days" {
  description = "Dias de retenção para dados do Prometheus"
  type        = number
  default     = 15
}

variable "storage_size" {
  description = "Tamanho de armazenamento para o Prometheus (em Gi)"
  type        = string
  default     = "10Gi"
}

variable "labels" {
  description = "Labels a serem aplicados nos recursos"
  type        = map(string)
  default     = {}
}