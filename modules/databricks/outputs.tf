output "databricks_host" {
  description = "URL do workspace Databricks"
  value       = var.databricks_host
}

output "cluster_id" {
  description = "ID do cluster Databricks criado"
  value       = databricks_cluster.data_processing.id
}

output "job_id" {
  description = "ID do job Databricks criado"
  value       = databricks_job.training_job.id
}

output "notebook_path" {
  description = "Caminho do notebook de testes no Databricks"
  value       = databricks_notebook.test_notebook.path
}

output "data_scientists_group" {
  description = "Nome do grupo de cientistas de dados"
  value       = databricks_group.data_scientists.display_name
}

output "ml_engineers_group" {
  description = "Nome do grupo de engenheiros de ML"
  value       = databricks_group.ml_engineers.display_name
}