##########################################################
# FILE: main.tf
# PROJECT: mlsecpix-infra
# DESCRIPTION:
# Arquivo principal que integra módulos de rede (VPC),
# GKE, armazenamento em camadas (arquitetura medallion),
# e jobs do Databricks. Segue princípios de Clean Code
# e boas práticas de MLSecOps, mantendo cada recurso
# em seu módulo dedicado e promovendo legibilidade.
#
# Este arquivo visa demonstrar um fluxo de infraestrutura
# como código limpo e modular. Em um ambiente real de
# produção, recomenda-se aprofundar configurações de
# segurança e observabilidade (como logs e auditorias),
# além de testes automatizados (por exemplo, usando
# Terratest). Nenhuma credencial sensível está hardcoded
# aqui, atendendo às políticas de compliance.
##########################################################

##########################################################
# BLOCO TERRAFORM
# - Define a versão mínima do Terraform e os providers
# requeridos, garantindo consistência de ambiente.
# - Em produção, poderíamos fixar versões exatas ou
# usar dependabot para manter atualizações seguras.
##########################################################

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.30"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.7"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }

  cloud {
    organization = "tf-mlsecpix-org"
    workspaces {
      name = "mlsecpix-workspace"
    }
  }
}

##########################################################
# LOCAIS (LOCALS)
# - Permitem padronizar nomenclaturas e reutilizar
# convenções de forma simples.
# - Aqui podem ser adicionadas regras de formatação de
# nomes, garantindo consistência (Clean Code).
##########################################################

locals {
  # Convenção de nomes, útil para padronizar recursos
  project_prefix = "mlsecpix"
  environment    = var.environment # Exemplo: dev, staging, prod

  # Notas de compliance podem ser incluídas ou vinculadas
  # a guidelines internas para rastreabilidade.
}

##########################################################
# MÓDULO: REDE (VPC)
# - Cria a VPC principal e sub-redes.
# - Em produção, poderíamos ter múltiplas sub-redes
# segmentadas por workload e regras de firewall
# integradas com Cloud Armor ou similares.
##########################################################

module "vpc" {
  source     = "./modules/vpc"
  project_id = var.gcp_project_id
  region     = var.gcp_region

  # Neste módulo exemplificamos a adoção de logs
  # de fluxo de rede e configurações de firewall
  # focadas em MLSecOps e privilégio mínimo.
}

##########################################################
# MÓDULO: GKE
# - Provisiona um cluster Kubernetes para rodar serviços
# como APIs e pipelines de ML, seguindo boas práticas
# de segurança (como Identity-Aware Proxy e RBAC).
# - Em ambiente real, usaríamos Managed Identities,
# e integrações com Secret Manager.
##########################################################

module "gke" {
  source          = "./modules/gke"
  project_id      = var.gcp_project_id
  region          = var.gcp_region
  vpc_self_link   = module.vpc.vpc_self_link
  subnet_self_link = module.vpc.subnet_self_link
  environment     = var.environment

  # Exemplo de rótulos de compliance e auditoria:
  labels = {
    "team"        = "mlsecops"
    "environment" = local.environment
    "component"   = "gke"
  }

  # Em produção, incluiríamos configurações avançadas
  # como Private Nodes, VPC Service Controls, etc.
}

##########################################################
# MÓDULO: STORAGE (ARQUITETURA MEDALLION)
# - Cria buckets para Bronze, Silver e Gold.
# - Em um uso real, ativaríamos versionamento de objetos,
# logs de acesso e criptografia com chaves gerenciadas.
##########################################################

module "storage" {
  source           = "./modules/storage"
  project_id       = var.gcp_project_id
  region           = var.gcp_region
  bronze_bucket_id = "${local.project_prefix}-${local.environment}-bronze"
  silver_bucket_id = "${local.project_prefix}-${local.environment}-silver"
  gold_bucket_id   = "${local.project_prefix}-${local.environment}-gold"
}

##########################################################
# MÓDULO: DATABRICKS JOBS
# - Configura notebooks e jobs de ETL/ML, já no workspace
# especificado nas variáveis. Poderia envolver clusters
# dedicados ou pools de computação.
# - Em produção, associaríamos a logs e monitoramento
# (Databricks Observability) e controle de acesso
# detalhado (ACLs, secrets).
##########################################################

module "databricks_jobs" {
  source             = "./modules/databricks-jobs"
  databricks_host    = var.databricks_host
  databricks_token   = var.databricks_token
  workspace_base_dir = "/Users/lugonc.lga@gmail.com/mlsecops-deteccao-fraudes-pix"
}

##########################################################
# EXEMPLO DE SAÍDAS
# - Podemos exportar informações essenciais para uso
# em outras camadas ou automação de testes (TDD/BDD).
# - Em produção, outputs podem ser mascarados se forem
# sensíveis. Aqui apenas ilustramos.
##########################################################

output "vpc_name" {
  description = "Nome da VPC criada."
  value       = module.vpc.vpc_name
}

output "gke_endpoint" {
  description = "Endpoint do cluster GKE."
  value       = module.gke.endpoint
}

output "bronze_bucket_name" {
  description = "Bucket da camada Bronze."
  value       = module.storage.bronze_bucket_name
}

output "databricks_jobs_info" {
  description = "Identificadores dos jobs provisionados no Databricks."
  value       = module.databricks_jobs.job_details
}
