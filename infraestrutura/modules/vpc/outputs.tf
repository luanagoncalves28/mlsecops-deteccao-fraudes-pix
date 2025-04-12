############################################################
# FILE: outputs.tf
# FOLDER: mlsecpix-infra/modules/databricks-jobs/
# DESCRIPTION:
#   Expõe informações relevantes sobre o cluster, notebooks 
#   e o job criados no Databricks para o projeto MLSecPix.
#   Segue Clean Code (nomes claros, modularização) e MLSecOps
#   (logs, rastreabilidade), adequando-se às fases 1, 2 e 3
#   do projeto de detecção de fraudes Pix. 
############################################################

############################################################
# OUTPUT: JOB CLUSTER ID
#   Identifica o cluster criado neste módulo, caso
#   seja necessário referenciá-lo para scripts ou 
#   monitoramentos. Em um contexto MLSecOps, podemos
#   auditar event logs ligados a este cluster.
############################################################
output "job_cluster_id" {
  description = "ID do cluster Databricks para rodar jobs de ETL/ML."
  value       = databricks_cluster.mlsecpix_job_cluster.id
}

############################################################
# OUTPUT: JOB CLUSTER NAME
#   Se quisermos exibir ou usar o nome do cluster 
#   em pipelines, relatórios ou integrações de compliance.
############################################################
output "job_cluster_name" {
  description = "Nome do cluster Databricks criado."
  value       = databricks_cluster.mlsecpix_job_cluster.cluster_name
}

############################################################
# OUTPUT: BRONZE_TO_SILVER NOTEBOOK PATH
#   Retorna o caminho do notebook importado,
#   útil se outro módulo ou script quiser acionar 
#   esse notebook dinamicamente.
############################################################
output "bronze_to_silver_notebook_path" {
  description = "Caminho do notebook Databricks para transformacao Bronze->Silver."
  value       = databricks_notebook.bronze_to_silver.path
}

############################################################
# OUTPUT: SILVER_TO_GOLD NOTEBOOK PATH
#   Idem ao anterior, mas para o notebook Silver->Gold.
############################################################
output "silver_to_gold_notebook_path" {
  description = "Caminho do notebook Databricks para transformacao Silver->Gold."
  value       = databricks_notebook.silver_to_gold.path
}

############################################################
# OUTPUT: JOB ID
#   Identificador do job, caso precisemos listar 
#   execuções, logs ou triggers externos. Em cenários 
#   de MLSecOps, consultamos logs do Databricks 
#   associando execuções a esse ID.
############################################################
output "job_id" {
  description = "ID do job Databricks que orquestra as tarefas de ETL."
  value       = databricks_job.mlsecpix_pipeline.id
}

############################################################
# OUTPUT: JOB NAME
#   O nome do job, referenciado em documentações ou 
#   integrações de monitoramento. Facilita a rastreabilidade 
#   e associação a auditorias de fraudes Pix.
############################################################
output "job_name" {
  description = "Nome do job Databricks (pipeline MLSecPix)."
  value       = databricks_job.mlsecpix_pipeline.name
}
