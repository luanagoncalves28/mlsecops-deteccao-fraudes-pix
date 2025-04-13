############################################################
# FILE: databricks.tf
# FOLDER: mlsecpix-infra/providers/
# DESCRIPTION:
#   Configura o provider para o Databricks utilizando
#   o novo namespace "databricks/databricks". Isso é 
#   necessário porque o registro oficial não disponibiliza
#   um provedor chamado "hashicorp/databricks". Segue os 
#   princípios de Clean Code e MLSecOps, utilizando variáveis
#   para garantir modularidade e segurança.
############################################################

terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"  # use o namespace correto
      version = "~> 1.72.0"
    }
  }
}

provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_token
}
