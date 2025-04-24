output "databricks_host" {
  description = "URL do workspace Databricks"
  value       = var.databricks_host
}

output "notebook_path" {
  description = "Caminho do notebook de testes no Databricks"
  value       = length(databricks_notebook.test_notebook) > 0 ? databricks_notebook.test_notebook[0].path : "Notebook não criado"
}

output "data_scientists_group" {
  description = "Nome do grupo de cientistas de dados"
  value       = length(databricks_group.data_scientists) > 0 ? databricks_group.data_scientists[0].display_name : "Grupo não criado"
}

output "ml_engineers_group" {
  description = "Nome do grupo de engenheiros de ML"
  value       = length(databricks_group.ml_engineers) > 0 ? databricks_group.ml_engineers[0].display_name : "Grupo não criado"
}