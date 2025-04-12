############################################################
# FILE: databricks.tf
# FOLDER: mlsecpix-infra/providers/
# DESCRIPTION:
#   Configuração do provider "databricks", que possibilita
#   gerenciar recursos no workspace Databricks: notebooks,
#   clusters, jobs, etc. Segue Clean Code e boas práticas
#   de MLSecOps, garantindo que o token de acesso não fique
#   exposto. Em ambientes críticos, marcamos essa variável
#   como sensível e evitamos logs com o valor do token.
#
#   Em produção real, recomenda-se integrar com secrets
#   (Databricks Secrets ou Vault) e usar políticas de acesso
#   robustas, principalmente se lidamos com dados de fraudes
#   Pix e requisitos da Resolução BCB nº 403.
############################################################

provider "databricks" {
  # "host" e "token" são variáveis sensíveis. 
  # No 'variables.tf', definimos "databricks_host" e 
  # "databricks_token". Seus valores reais são supridos 
  # pelo tfvars ou pelo Terraform Cloud.  
  host  = var.databricks_host
  token = var.databricks_token

  # Em um cenário real, poderíamos configurar
  # "azure_databricks_resource_id" ou "google_service_account"
  # se estivermos integrados com outras clouds. 
  # A abordagem aqui é simplificada para este projeto 
  # MLSecPix, focado no Databricks workspace em 
  # https://dbc-7a058f2d-3d4b.cloud.databricks.com
}
