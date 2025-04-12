############################################################
# FILE: variables.tf
# FOLDER: mlsecpix-infra/modules/databricks-jobs/
# DESCRIPTION:
#   Declara as variáveis necessárias para configurar os
#   recursos do Databricks Jobs para o projeto MLSecPix.
#
#   Esse arquivo define parâmetros essenciais para:
#     - Identificar o ambiente de execução (dev, staging, prod)
#     - Localizar o diretório base do Databricks, onde os 
#       notebooks serão armazenados
#     - Configurar o cluster dedicado que executará os jobs,
#       incluindo nome, versão do Spark, tipo de nó, número de
#       workers e tempo de autoencerramento
#     - Configurar o job que orquestra a execução dos 
#       notebooks (ex.: transformação de dados entre as 
#       camadas Bronze, Silver e Gold)
#
#   Essa abordagem atende os requisitos das fases 1, 2 e 3 do
#   projeto (Análise Regulatória, Tradução para Requisitos 
#   Técnicos e Design Arquitetural) e segue princípios de Clean 
#   Code e MLSecOps, garantindo modularidade, segurança e 
#   rastreabilidade para auditoria e compliance.
############################################################

variable "environment" {
  type        = string
  description = "Nome do ambiente para a execução (dev, staging, prod)."
  default     = "dev"
}

variable "workspace_base_dir" {
  type        = string
  description = "Diretório base no Databricks onde os notebooks serão importados (ex.: /Users/lugonc.lga@gmail.com/mlsecops-deteccao-fraudes-pix)."
  default     = "/Users/lugonc.lga@gmail.com/mlsecops-deteccao-fraudes-pix"
}

variable "cluster_name" {
  type        = string
  description = "Nome do cluster Databricks que executará os jobs de ML/ETL."
  default     = "mlsecpix-job-cluster"
}

variable "spark_version" {
  type        = string
  description = "Versão do Spark a ser utilizada no cluster (ex.: 11.3.x-scala2.12)."
  default     = "11.3.x-scala2.12"
}

variable "node_type_id" {
  type        = string
  description = "Tipo de nó para os workers do cluster (ex.: i3.xlarge)."
  default     = "i3.xlarge"
}

variable "autotermination_minutes" {
  type        = number
  description = "Tempo de autoencerramento do cluster em minutos (para reduzir custos em ambiente dev)."
  default     = 30
}

variable "num_workers" {
  type        = number
  description = "Número de workers (nós) para o cluster Databricks."
  default     = 2
}

variable "job_name" {
  type        = string
  description = "Nome do job Databricks que orquestra os notebooks de transformação (pipeline MLSecPix)."
  default     = "mlsecpix-pipeline"
}

variable "job_cron" {
  type        = string
  description = "Expressão CRON para agendamento do job (ex.: '0 3 * * * ?' para executar às 3h da manhã diariamente)."
  default     = "0 3 * * * ?"
}

variable "job_owner" {
  type        = string
  description = "Identificador ou nome do proprietário do job, usado para tags e auditoria."
  default     = "mlsecops-team"
}
