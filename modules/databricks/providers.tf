terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.19.0"  # Use a versão mais recente disponível
    }
  }
}

# Adicione isso ao arquivo iac/providers.tf existente

############################################################
# DATABRICKS – usa o token para autenticação
############################################################
provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_token
}