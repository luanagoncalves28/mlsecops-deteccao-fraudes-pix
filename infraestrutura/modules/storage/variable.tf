############################################################
# FILE: variables.tf
# FOLDER: mlsecpix-infra/modules/storage/
# DESCRIPTION:
# Declara as variáveis necessárias para criar os buckets
# da arquitetura medallion (Bronze, Silver, Gold).
# Segue Clean Code e MLSecOps, evitando strings mágicas
# e garantindo configurabilidade (ex.: versionamento).
#
# Em projetos de detecção de fraudes Pix (MLSecPix),
# versionamento e rótulos (labels) são fundamentais
# para auditoria e rastreabilidade, atendendo
# normas como BCB nº 403.
############################################################

############################################################
# PROJETO E REGIÃO
# Definimos onde serão criados os buckets no GCP.
############################################################

variable "project_id" {
  type        = string
  description = "ID do projeto GCP onde os buckets serão criados."
}

variable "region" {
  type        = string
  description = "Região em que os buckets GCS serão criados (ex.: US, EU, ASIA)."
  default     = "US"
}

############################################################
# NOMES DOS BUCKETS (ARQUITETURA MEDALLION)
# Cada bucket representando um estágio: Bronze, Silver, Gold.
############################################################

variable "bronze_bucket_id" {
  type        = string
  description = "Nome do bucket Bronze (dados brutos)."
}

variable "silver_bucket_id" {
  type        = string
  description = "Nome do bucket Silver (dados limpos)."
}

variable "gold_bucket_id" {
  type        = string
  description = "Nome do bucket Gold (dados finais e refinados)."
}

############################################################
# VERSIONAMENTO
# Em MLSecOps, habilitar versioning nos buckets
# ajuda na auditoria, prevenindo perda ou manipulação
# indevida de dados críticos (fase 1 e 2 do MLSecPix).
############################################################

variable "enable_versioning" {
  type        = bool
  description = "Ativar versionamento em cada bucket (arquitetura medallion)?"
  default     = true
}

############################################################
# LABELS
# Rótulos que facilitam rastreamento de custos e
# compliance. Ex.: environment = dev, product = mlsecpix.
############################################################

variable "labels" {
  type        = map(string)
  description = "Mapeamento de rótulos para identificar os buckets."
  default = {
    environment = "dev"
    product     = "mlsecpix"
  }
}
