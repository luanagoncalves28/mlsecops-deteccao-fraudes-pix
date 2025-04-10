# Ambiente de Produção - outputs.tf
# Autor: Luana Gonçalves
# Data: Abril 2025

# Informações do projeto
output "project_id" {
  description = "ID do projeto GCP"
  value       = var.project_id
}

output "region" {
  description = "Região do GCP"
  value       = var.region
}

output "environment" {
  description = "Ambiente atual"
  value       = var.environment
}

# Informações de armazenamento
output "storage_buckets" {
  description = "Nomes dos buckets criados"
  value       = module.armazenamento.bucket_names
}

output "storage_urls" {
  description = "URLs dos buckets criados"
  value       = module.armazenamento.bucket_urls
}

# Informações de rede
output "vpc_name" {
  description = "Nome da rede VPC"
  value       = module.rede.vpc_name
}

output "subnet_name" {
  description = "Nome da subrede"
  value       = module.rede.subnet_name
}

# Informações do GKE
output "kubernetes_cluster_name" {
  description = "Nome do cluster GKE"
  value       = module.gke.kubernetes_cluster_name
}

output "kubernetes_cluster_endpoint" {
  description = "Endpoint do cluster GKE"
  value       = module.gke.kubernetes_cluster_endpoint
  sensitive   = true
}