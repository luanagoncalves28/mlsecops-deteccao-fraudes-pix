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

########################################################################
# Módulo de bootstrap no cluster GKE  – namespace “ml” + WorkloadIdentity
########################################################################
module "k8s_bootstrap" {
  source = "../modules/k8s_bootstrap"

  # variáveis que o módulo espera
  project_id = var.gcp_project_id
  region     = var.gcp_region

  # usa o provider kubernetes “gke” definido em providers.tf
  providers = {
    kubernetes = kubernetes.gke
  }
}

###############################################################################
# 6. Módulo de Monitoramento - Prometheus e Grafana para observabilidade
###############################################################################
module "monitoring" {
  source = "../modules/monitoring"

  project_id  = var.gcp_project_id
  region      = var.gcp_region
  environment = var.environment
  
  # Obtém o nome do cluster do módulo GKE
  cluster_name = module.gke.cluster_name
  
  # Configurações específicas de monitoramento
  prometheus_namespace   = "monitoring"
  grafana_admin_password = "MLSecOps@2025"  # Em produção, use um secret gerenciado
  retention_days         = 15
  storage_size           = "10Gi"
  
  labels = {
    product = "mlsecpix"
  }

  # Depende do módulo k8s_bootstrap para garantir que o cluster esteja configurado primeiro
  depends_on = [module.k8s_bootstrap]
}