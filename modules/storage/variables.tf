variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "labels" {
  description = "Labels comuns a todos os buckets"
  type        = map(string)
  default     = {}
}

/* retenção em dias para cada tier (podemos reutilizar em prod) */
variable "retention_bronze_days" {
  type    = number
  default = 90
}

variable "retention_silver_days" {
  type    = number
  default = 365
}

variable "retention_gold_days" {
  type    = number
  default = 0          # 0 = indefinido
}

variable "retention_audit_hot" {
  type    = number
  default = 30
}

variable "retention_audit_cold" {
  type    = number
  default = 365
}