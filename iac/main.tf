###############################################################
# Root – orquestração dos módulos de infraestrutura
###############################################################
terraform {
  required_version = ">= 1.5"
}

######################## 1. VPC ################################
module "vpc" {
  source       = "../modules/vpc"
  project_id   = var.gcp_project_id
  region       = var.gcp_region
  environment  = var.environment

  network_name = "mlsecpix-${var.environment}-vpc"
  subnet_cidr  = "10.10.0.0/24"
}

######################## 2. Storage ############################
module "storage" {
  source      = "../modules/storage"
  project_id  = var.gcp_project_id
  region      = var.gcp_region
  environment = var.environment
  labels      = { product = "mlsecpix" }
}

######################## 3. IAM ################################
module "iam" {
  source      = "../modules/iam"
  project_id  = var.gcp_project_id
  region      = var.gcp_region
  environment = var.environment
  labels      = { product = "mlsecpix" }
}

######################## 4. GKE ################################
module "gke" {
  source      = "../modules/gke"
  project_id  = var.gcp_project_id
  region      = var.gcp_region
  environment = var.environment
  network     = module.vpc.network
  subnet      = module.vpc.subnet
  labels      = { product = "mlsecpix" }
}

######################## 5. K8s‑bootstrap ######################
module "k8s_bootstrap" {
  source      = "../modules/k8s_bootstrap"
  project_id  = var.gcp_project_id
  region      = var.gcp_region

  # ❌ alias removido – o módulo vai usar o provider kubernetes default
}

######################## 6. Monitoring #########################
module "monitoring" {
  source      = "../modules/monitoring"
  project_id  = var.gcp_project_id
  region      = var.gcp_region
  environment = var.environment

  cluster_name           = module.gke.name
  prometheus_namespace   = "monitoring"
  grafana_admin_password = var.grafana_admin_password
  retention_days         = 15
  storage_size           = "10Gi"

  labels = { product = "mlsecpix" }

  depends_on = [
    module.gke,
    module.k8s_bootstrap
  ]
}

######################## 7. Artifact ###########################
module "artifact" {
  source      = "../modules/artifact"
  project_id  = var.gcp_project_id
  region      = var.gcp_region
  environment = var.environment
  repository_id               = "mlsecpix-images"
  enable_cloudbuild_trigger   = false
  labels = { product = "mlsecpix" }
}

######################## 8. Databricks #########################
module "databricks" {
  source                         = "../modules/databricks"
  project_id                     = var.gcp_project_id
  region                         = var.gcp_region
  environment                    = var.environment
  databricks_host                = var.databricks_host
  databricks_token               = var.databricks_token
  enable_databricks_resources    = false
  databricks_cluster_name        = "mlsecpix-data-cluster"
  databricks_job_name            = "mlsecpix-training-job"
  spark_version                  = "11.3.x-scala2.12"
  node_type_id                   = "n1-standard-4"
  autoscale_min_workers          = 1
  autoscale_max_workers          = 4
  labels = { product = "mlsecpix" }
}

######################## 9. Backup ###########################
module "backup" {
  source      = "../modules/backup"
  project_id  = var.gcp_project_id
  region      = var.gcp_region
  environment = var.environment
  labels      = { product = "mlsecpix" }
  
  depends_on = [
    module.storage
  ]
}