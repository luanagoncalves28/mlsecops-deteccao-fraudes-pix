output "project_info" {
  description = "Informações básicas do projeto"
  value = {
    project_id = var.project_id
    region     = var.region
    zone       = var.zone
  }
}

output "labels_padrao" {
  description = "Labels padrão aplicados aos recursos"
  value       = var.labels_padrao
}
