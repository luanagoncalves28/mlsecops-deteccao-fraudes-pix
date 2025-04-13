############################################################
# FILE: outputs.tf
# FOLDER: mlsecpix-infra/modules/databricks-jobs/
# DESCRIPTION:
# Expõe informações relevantes sobre o cluster, notebooks
# e o job criados no Databricks para o projeto MLSecPix.
# Segue Clean Code (nomes claros, modularização) e MLSecOps
# (logs, rastreabilidade), adequando-se às fases 1, 2 e 3
# do projeto de detecção de fraudes Pix.
############################################################

############################################################
# OUTPUT: JOB DETAILS
# Detalhes do job criado para uso externo.
# Em um projeto real, poderia incluir mais informações.
############################################################

output "job_details" {
  description = "Detalhes do job Databricks criado."
  value = {
    job_id   = databricks_job.mlsecpix_pipeline.id
    job_name = databricks_job.mlsecpix_pipeline.name
  }
}

############################################################
# OUTPUT: CLUSTER ID
# Identificador do cluster criado para uso externo.
############################################################

output "cluster_id" {
  description = "ID do cluster Databricks criado."
  value = databricks_cluster.mlsecpix_job_cluster.id
}

############################################################
# OUTPUT: NOTEBOOK PATHS
# Caminhos dos notebooks criados para referência externa.
############################################################

output "notebook_paths" {
  description = "Caminhos dos notebooks Databricks criados."
  value = {
    bronze_to_silver = databricks_notebook.bronze_to_silver.path
    silver_to_gold   = databricks_notebook.silver_to_gold.path
  }
}
