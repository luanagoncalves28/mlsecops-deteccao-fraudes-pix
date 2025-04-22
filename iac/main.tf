###############################################################
#  Root – orquestração dos módulos de infraestrutura
###############################################################

terraform {
  required_version = ">= 1.5"
}

###############################################################
# 1. Módulo de VPC (já aplicado no run INFRA‑001)
###############################################################
module "vpc" {
  source = "../modules/vpc"

  project_id   = var.gcp_project_id
  region       = var.gcp_region
  environment  = var.environment

  # >>> parâmetros obrigatórios do módulo
  network_name = "mlsecpix-${var.environment}-vpc"
  subnet_cidr  = "10.10.0.0/24"
}

###############################################################
# 2. Módulo de Storage (data‑lake + buckets de auditoria)
###############################################################
module "storage" {
  source = "../modules/storage"

  project_id  = var.gcp_project_id
  region      = var.gcp_region
  environment = var.environment

  labels = {
    product = "mlsecpix"
  }

  # Descomente p/ sobrescrever retenções padrão
  # retention_bronze_days = 90
  # retention_silver_days = 365
  # retention_gold_days   = 0
  # retention_audit_hot   = 30
  # retention_audit_cold  = 365
}

# EOF

###############################################################################
# 3. Módulo de IAM – Service Accounts + RBAC
###############################################################################
module "iam" {
  source      = "../modules/iam"

  project_id  = var.gcp_project_id
  region      = var.gcp_region
  environment = var.environment

  labels = {
    product = "mlsecpix"
  }
}

################################################################################
# 3. Módulo de GKE – cluster autopilot para workloads de ML/serving
################################################################################
module "gke" {
  source = "../modules/gke"

  project_id  = var.gcp_project_id
  region      = var.gcp_region
  environment = var.environment

 network = module.vpc.network   # self_link da rede
 subnet  = module.vpc.subnet    # self_link da sub‑rede

  labels = {
    product = "mlsecpix"
  }
}