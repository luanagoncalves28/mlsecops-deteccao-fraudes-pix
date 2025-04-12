############################################################
# FILE: terraform.tfvars
# PROJECT: mlsecpix-infra
# DESCRIPTION:
#   Definições de valores para as variáveis declaradas
#   em variables.tf. Nesta abordagem, inserimos exemplos
#   de placeholders para cada campo. Em um ambiente real,
#   recomenda-se usar o Terraform Cloud com variáveis
#   marcadas como sensíveis ou um gerenciador de segredos.
#
#   Em conformidade com Clean Code e MLSecOps, evitamos
#   expor credenciais críticas em repositórios públicos
#   ou logs. 
############################################################

############################################################
# VALORES GCP
# - Substitua pelos IDs e caminhos reais no seu cenário.
############################################################
gcp_project_id       = "mlsecpix-456600"
gcp_region           = "southamerica-east1"
gcp_zone             = "southamerica-east1-b"
gcp_credentials_file = "/caminho/para/mlsecpix-456600-cs-terraform.json"

############################################################
# VALORES DATABRICKS
# - Em produção, usar Terrafrom Cloud e marcar como 
#   sensível, evitando plaintext local.
############################################################
databricks_host  = "https://dbc-7a058f2d-3d4b.cloud.databricks.com"
databricks_token = "dapif1be095d76bc23121212da689f78a77a"

############################################################
# VALORES GITHUB
# - Se estiver usando Terraform para gerenciar algo no GitHub.
# - Novamente, cuidado para não expor tokens em repositórios 
#   ou logs.
############################################################
github_token = "github_pat_11AXAI4NI0DfpsmBdoeryb_8Ep9xqcSgJRvqOF5pvEUUz0SmgWqP4M9wkIRwQadDpt..."

############################################################
# AMBIENTE
# - Indica se está provisionando dev, staging ou prod.
# - Em produção, às vezes temos workspaces separados.
############################################################
environment = "dev"
