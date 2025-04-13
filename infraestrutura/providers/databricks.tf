############################################################
# FILE: databricks.tf
# FOLDER: mlsecpix-infra/providers/
# DESCRIPTION:
# Configura o provider para o Databricks utilizando
# o namespace correto "databricks/databricks". Isso é
# necessário porque o registro oficial não está no namespace
# hashicorp. Segue os princípios de Clean Code e MLSecOps,
# utilizando variáveis para garantir modularidade e segurança.
############################################################

terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.7.0"
    }
  }
}

provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_token
}
