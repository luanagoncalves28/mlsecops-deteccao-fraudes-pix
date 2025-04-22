variable "project_id" {
  description = "ID do projeto GCP onde o workload rodará"
  type        = string
}

variable "region" {
  description = "Região GCP (só usamos para manter padrão nos recursos)"
  type        = string
}