############################################################
# FILE: google.tf
# FOLDER: mlsecpix-infra/providers/
# DESCRIPTION:
#   Configuração do provider "google", apontando
#   para as variáveis que definem o projeto, região,
#   zona e credenciais de serviço (JSON).
#   Segue princípios de Clean Code e MLSecOps,
#   mantendo segurança, separação de responsabilidades
#   e rastreabilidade. 
#
#   Em um ambiente real de produção, recomenda-se
#   habilitar recursos adicionais de auditoria e
#   logs (ex.: Stackdriver Logging, VPC Flow Logs)
#   para cumprir requisitos regulatórios (BCB nº 403)
#   e de segurança. Não colocamos nada hardcoded 
#   para evitar vazamentos de credenciais.
############################################################

# O bloco de provider do Google referencia variáveis
# declaradas em variables.tf (gcp_credentials_file, 
# gcp_project_id, gcp_region e gcp_zone). Isso garante 
# que nenhuma credencial sensível fique diretamente no código.
provider "google" {
  credentials = file(var.gcp_credentials_file)
  project     = var.gcp_project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
}
