##############################################
# Root – orquestração de módulos de infraestrutura
##############################################

terraform {
  required_version = ">= 1.5"
}

##############################################
# 1. Módulo de VPC  (já existente)
##############################################
module "vpc" {
  source      = "./modules/vpc"

  project_id  = var.gcp_project_id
  region      = var.gcp_region
  environment = var.environment

  labels = {
    product = "mlsecpix"
  }
}

##############################################
# 2. Módulo de Storage (data‑lake + auditoria)
##############################################
module "storage" {
  source      = "./modules/storage"

  project_id  = var.gcp_project_id
  region      = var.gcp_region
  environment = var.environment

  labels = {
    product = "mlsecpix"
  }

  # — opcional: sobrescreva retenções padrão aqui se quiser —
  # retention_bronze_days = 90
  # retention_silver_days = 365
  # retention_gold_days   = 0
  # retention_audit_hot   = 30
  # retention_audit_cold  = 365
}