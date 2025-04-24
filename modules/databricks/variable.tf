variable "project_id" {
  description = "ID do projeto GCP onde o Databricks será provisionado"
  type        = string
}

variable "region" {
  description = "Região do GCP onde o Databricks será provisionado"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "databricks_host" {
  description = "URL do workspace Databricks"
  type        = string
}

variable "databricks_token" {
  description = "Token de acesso ao Databricks"
  type        = string
  sensitive   = true
}

variable "databricks_cluster_name" {
  description = "Nome do cluster Databricks para processamento de dados"
  type        = string
  default     = "mlsecpix-data-cluster"
}

variable "databricks_job_name" {
  description = "Nome do job Databricks para treinamento"
  type        = string
  default     = "mlsecpix-training-job"
}

variable "spark_version" {
  description = "Versão do Spark a ser utilizada no cluster"
  type        = string
  default     = "11.3.x-scala2.12" # LTS version
}

variable "node_type_id" {
  description = "Tipo de instância para os nodes do cluster"
  type        = string
  default     = "n1-standard-4" # Ou equivalente no GCP
}

variable "autoscale_min_workers" {
  description = "Número mínimo de workers no autoscaling"
  type        = number
  default     = 1
}

variable "autoscale_max_workers" {
  description = "Número máximo de workers no autoscaling"
  type        = number
  default     = 4
}

variable "labels" {
  description = "Labels a serem aplicados nos recursos"
  type        = map(string)
  default     = {}
}