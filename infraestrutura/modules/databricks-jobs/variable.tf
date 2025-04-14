############################################################
# FILE: variables.tf
# FOLDER: mlsecpix-infra/modules/databricks-jobs/
# DESCRIPTION:
# Define as variáveis necessárias para criar e gerenciar
# um cluster, notebooks e um job no Databricks, focando
# em um pipeline de detecção de fraudes Pix (MLSecPix).
# Este arquivo complementa o main.tf e segue Clean Code
# e MLSecOps: cada parâmetro é configurável e não
# hardcoded, garantindo segurança, rastreabilidade e
# adequação às fases 1, 2 e 3 do projeto.
############################################################

############################################################
# AMBIENTE (DEV, STAGING, PROD)
# Pode ser usado para rotular recursos no Databricks
# (ex.: "dev", "mlsecpix") e gerar tags que auxiliam
# na auditoria e conformidade com BCB nº 403.
############################################################

variable "environment" {
  type        = string
  description = "Nome do ambiente (dev, staging, prod)."
  default     = "dev"
}

############################################################
# BASE DO WORKSPACE (DIRETÓRIO)
# Onde os notebooks serão importados. Exemplo:
# "/Users/lugonc.lga@gmail.com/mlsecops-deteccao-fraudes-pix"
############################################################

variable "workspace_base_dir" {
  type        = string
  description = "Diretório base onde os notebooks serão importados no Databricks."
  default     = "/Users/lugonc.lga@gmail.com/mlsecops-deteccao-fraudes-pix"
}

############################################################
# CLUSTER SETTINGS
# Parâmetros para criar um cluster dedicado (caso não
# usemos 'existing_cluster_id'). Em produção, pode
# haver configurações extras como Spark config,
# autoscaling, ACLs, etc.
############################################################

variable "cluster_name" {
  type        = string
  description = "Nome do cluster Databricks."
  default     = "mlsecpix-job-cluster"
}

variable "spark_version" {
  type        = string
  description = "Versão do Spark no Databricks (ex.: 11.3.x-scala2.12)."
  default     = "11.3.x-scala2.12"
}

variable "node_type_id" {
  type        = string
  description = "Tipo de nó (ex.: 'Standard_DS3_v2', 'n1-standard-4')."
  default     = "n1-standard-4"
}

variable "autotermination_minutes" {
  type        = number
  description = "Tempo em minutos para encerrar cluster ocioso (MLSecOps: poupar custo)."
  default     = 30
}

variable "num_workers" {
  type        = number
  description = "Número de workers do cluster."
  default     = 0  # Single node cluster
}

############################################################
# JOB CONFIG
# Nome do job, schedule (cron), owner, etc.
# Em um projeto MLSecOps real, definimos triggers
# automáticos, e logs de auditoria do job.
############################################################

variable "job_name" {
  type        = string
  description = "Nome do job Databricks que orquestra notebooks."
  default     = "mlsecpix-pipeline"
}

variable "job_cron" {
  type        = string
  description = "Expressão CRON para agendar o job (ex.: 0 2 * * * ?)."
  default     = "0 3 * * * ?"
  # 3h da manhã todos os dias
  # Ajuste conforme necessidade
}

variable "job_owner" {
  type        = string
  description = "Tag que indica o responsável pelo job."
  default     = "mlsecops-team"
}

############################################################
# DATABRICKS CONNECTION
# Informações de conexão com o Databricks.
# Estas variáveis são injetadas do módulo raiz.
############################################################

variable "databricks_host" {
  type        = string
  description = "URL do workspace Databricks."
}

variable "databricks_token" {
  type        = string
  description = "Token de acesso ao Databricks."
  sensitive   = true
}
