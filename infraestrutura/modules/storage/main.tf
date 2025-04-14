############################################################
# FILE: main.tf
# FOLDER: mlsecpix-infra/modules/storage/
# DESCRIPTION:
# Cria três buckets GCS (Bronze, Silver e Gold), refletindo
# a arquitetura medallion típica de pipelines de ML e dados,
# fundamental para o projeto fictício MLSecPix. Segue
# princípios de Clean Code e MLSecOps, incluindo:
# - versionamento de objetos para auditoria e compliance
# - rotulagem para rastreamento de custos e conformidade
#
# Em cenários de detecção de fraudes Pix, manter histórico
# (via versionamento) e logs de acesso a cada camada
# (bronze, silver, gold) ajuda a atender requisitos
# regulatórios como a Resolução BCB nº 403, garantindo
# evidências de cada alteração de dados e pipeline.
############################################################

############################################################
# RECURSOS: ARQUITETURA MEDALLION
# - google_storage_bucket "bronze"
# - google_storage_bucket "silver"
# - google_storage_bucket "gold"
#
# VARIÁVEIS:
# - Recebidas via variables.tf (project_id, region,
# bronze_bucket_id, silver_bucket_id, gold_bucket_id,
# enable_versioning, labels).
############################################################

# Bucket Bronze: dados brutos sem limpeza.
resource "google_storage_bucket" "bronze" {
  name     = var.bronze_bucket_id
  project  = var.project_id
  location = var.region

  # Em compliance com BCB nº 403, ativamos versionamento
  # para manter histórico de alterações e provar integridade
  # dos dados em cenários de auditoria.
  versioning {
    enabled = var.enable_versioning
  }

  # Rótulos para rastreamento, compliance, e custo.
  labels = var.labels

  # Em produção, podemos usar criptografia KMS ou
  # logs de acesso se exigido por regulamentos internos
  # ou LGPD, definindo "uniform_bucket_level_access = true"
  # e "retention_policy".
}

# Bucket Silver: dados já limpos e estruturados para
# consumos analíticos. Podem conter dados transformados
# após processos de validação (fase 2 e 3 do MLSecPix).
resource "google_storage_bucket" "silver" {
  name     = var.silver_bucket_id
  project  = var.project_id
  location = var.region
  
  versioning {
    enabled = var.enable_versioning
  }
  
  labels = var.labels
}

# Bucket Gold: dados prontos para consumo final (modelos,
# relatórios, dashboards). Em MLSecOps, esse bucket
# contempla dados que foram certificados e podem
# alimentar modelos de ML em Databricks, por exemplo.
resource "google_storage_bucket" "gold" {
  name     = var.gold_bucket_id
  project  = var.project_id
  location = var.region
  
  versioning {
    enabled = var.enable_versioning
  }
  
  labels = var.labels
}
