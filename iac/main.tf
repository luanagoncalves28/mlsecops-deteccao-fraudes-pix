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
  
  # Usando a saída do módulo GKE
  cluster_name = module.gke.name
  
  prometheus_namespace   = "monitoring"
  grafana_admin_password = "MLSecOps@2025"  # Em produção, use um secret gerenciado
  retention_days         = 15
  storage_size           = "10Gi"
  
  labels = {
    product = "mlsecpix"
  }

  # Dependências explícitas para garantir a ordem correta de criação
  depends_on = [
    module.gke,
    module.k8s_bootstrap
  ]

  # Certifica-se de que o provider Kubernetes está configurado após o cluster estar disponível
  providers = {
    kubernetes = kubernetes
  }
}

###############################################################################
# 7. Módulo de Pipeline de Imagens - Artifact Registry + Cloud Build
###############################################################################
module "artifact" {
  source = "../modules/artifact"

  project_id  = var.gcp_project_id
  region      = var.gcp_region
  environment = var.environment
  
  # Nome do repositório do Artifact Registry
  repository_id = "mlsecpix-images"
  
  # Desabilitar a criação do trigger do Cloud Build até que a API esteja habilitada
  enable_cloudbuild_trigger = false
  
  labels = {
    product = "mlsecpix"
  }
}

###############################################################################
# 8. Módulo Databricks - Workspace, Clusters e Jobs para ML
###############################################################################
module "databricks" {
  source = "../modules/databricks"

  project_id  = var.gcp_project_id
  region      = var.gcp_region
  environment = var.environment
  
  # Conexão com o Databricks
  databricks_host  = var.databricks_host
  databricks_token = var.databricks_token
  
  # Desabilitar a criação de recursos Databricks até que a conta esteja ativa
  enable_databricks_resources = false
  
  # Configurações dos recursos
  databricks_cluster_name = "mlsecpix-data-cluster"
  databricks_job_name     = "mlsecpix-training-job"
  
  # Configurações do cluster
  spark_version         = "11.3.x-scala2.12"
  node_type_id          = "n1-standard-4"
  autoscale_min_workers = 1
  autoscale_max_workers = 4
  
  labels = {
    product = "mlsecpix"
  }
}