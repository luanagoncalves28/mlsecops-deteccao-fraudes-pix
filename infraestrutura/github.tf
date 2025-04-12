############################################################
# FILE: github.tf
# FOLDER: mlsecpix-infra/providers/
# DESCRIPTION:
#   Configuração do provider "github", permitindo ao 
#   Terraform gerenciar repositórios, webhooks, equipes, 
#   etc., no GitHub. Segue princípios de Clean Code e 
#   MLSecOps: mantemos o token como variável sensível,
#   isolamos o provider em um arquivo dedicado, e 
#   documentamos práticas de compliance e segurança.
#
#   Em um projeto real de MLSecOps, poderíamos automatizar
#   criação de webhooks para CI/CD e escaneamento de 
#   segurança, garantindo rastreabilidade e logs para 
#   requisitos regulatórios (fase 1, 2, 3).
############################################################

# Precisamos do "github_token" declarado em variables.tf 
# (marcado como sensitive = true). Em um ambiente real, 
# convém usar Terraform Cloud ou um cofre de segredos para 
# armazenar este token, não expondo-o em nenhum repositório
# público. 
provider "github" {
  token        = var.github_token
  # Se você for gerenciar recursos em uma organização 
  # específica, pode definir:
  # organization = "nome-da-org-no-github"
  #
  # Se for gerenciar repositórios pessoais, 
  # pode omitir "organization" e gerenciar via "owner".
  # Exemplo:
  # owner = "seu-usuario"
}
