############################################################
# FILE: databricks.tf
# FOLDER: mlsecpix-infra/providers/
# DESCRIPTION:
# Configura o provider para o Databricks utilizando
# o namespace "databricks/databricks". Isso é
# necessário porque o registro oficial não disponibiliza
# um provedor chamado "hashicorp/databricks". Segue os
# princípios de Clean Code e MLSecOps, utilizando variáveis
# para garantir modularidade e segurança.
############################################################

provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_token
}
