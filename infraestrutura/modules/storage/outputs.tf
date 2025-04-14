############################################################
# FILE: outputs.tf
# FOLDER: mlsecpix-infra/modules/storage/
# DESCRIPTION:
# Expõe informações importantes (nomes, links) dos buckets
# Bronze, Silver e Gold, reforçando o conceito de
# arquitetura medallion no projeto MLSecPix. Em cenários
# de detecção de fraudes Pix, ter referências claras
# (outputs) é essencial para pipelines e compliance
# (fase 1, 2 e 3).
#
# Segue Clean Code: cada output tem nome semântico,
# e mantemos a lógica de criação em main.tf, enquanto
# outputs ficam organizados aqui.
############################################################

############################################################
# OUTPUT: BRONZE BUCKET NAME
# Retorna o nome real do bucket Bronze.
# Se algum pipeline for apontar para este bucket,
# basta usar `module.storage.bronze_bucket_name`.
############################################################

output "bronze_bucket_name" {
  description = "Nome do bucket GCS para dados brutos (Bronze)."
  value       = google_storage_bucket.bronze.name
}

############################################################
# OUTPUT: BRONZE BUCKET URL
# Exemplo de self-link ou URL para integrar em
# pipelines e provar conformidade (ex.: logs).
############################################################

output "bronze_bucket_url" {
  description = "URL do bucket Bronze, útil para configurações."
  value       = google_storage_bucket.bronze.url
}

############################################################
# OUTPUT: SILVER BUCKET NAME
# Dados limpos e estruturados. Retornar o nome
# facilita a automação de notebooks ou scripts.
############################################################

output "silver_bucket_name" {
  description = "Nome do bucket GCS para dados Silver."
  value       = google_storage_bucket.silver.name
}

output "silver_bucket_url" {
  description = "URL do bucket Silver."
  value       = google_storage_bucket.silver.url
}

############################################################
# OUTPUT: GOLD BUCKET NAME
# Dados finais prontos para consumo. Em MLSecOps,
# esse bucket pode armazenar dados validados,
# garantindo integridade e conformidade
# (fase 1, 2, 3 do MLSecPix).
############################################################

output "gold_bucket_name" {
  description = "Nome do bucket GCS para dados Gold."
  value       = google_storage_bucket.gold.name
}

output "gold_bucket_url" {
  description = "URL do bucket Gold."
  value       = google_storage_bucket.gold.url
}
