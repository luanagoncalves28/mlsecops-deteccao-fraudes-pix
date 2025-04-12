############################################################
# FILE: google.tf
# FOLDER: mlsecpix-infra/providers/
# DESCRIPTION:
#   Configuração do provider "google" para o projeto MLSecPix.
#   Utiliza a variável "gcp_sa_credentials_b64" para decodificar
#   a chave de conta de serviço em base64, garantindo que as
#   credenciais não fiquem hardcoded ou expostas no repositório.
#
#   Essa configuração atende aos requisitos das fases 1, 2 e 3,
#   permitindo rastreabilidade, auditoria e segurança (compliance 
#   com, por exemplo, a Resolução BCB nº 403), além de seguir 
#   práticas de Clean Code.
############################################################

provider "google" {
  credentials = base64decode(var.gcp_sa_credentials_b64)
  project     = var.gcp_project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
}
