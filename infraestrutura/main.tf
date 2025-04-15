############################################################
# FILE: main.tf
# FOLDER: mlsecpix-infra/modules/databricks-jobs/
# DESCRIPTION:
# Cria recursos no workspace Databricks para sustentar o
# pipeline de detecção de fraudes Pix (MLSecPix). Exemplos:
# - Um cluster dedicado para jobs
# - Notebooks que processam dados (bronze->silver->gold)
# - Um job que executa esses notebooks em sequência
#
# Em projetos MLSecOps, é fundamental manter rastreabilidade
# (quem rodou, quando, logs de execução), e evitar tokens
# hardcoded. Aqui usamos var.databricks_host e
# var.databricks_token, atendendo às fases 1, 2, 3 do
# MLSecPix e princípios de Clean Code.
############################################################

terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.7"
    }
  }
}

############################################################
# RECURSO: CLUSTER DEDICADO
# Poderíamos usar "existing_cluster_id" se já houvesse
# um cluster. Aqui, criamos um cluster para jobs
# exemplificando um fluxo real de ETL/ML.
# Em produção, poderíamos configurar auto-termination,
# Spark version, node types, entre outros.
############################################################

resource "databricks_cluster" "mlsecpix_job_cluster" {
  cluster_name            = var.cluster_name
  spark_version           = "11.3.x-scala2.12"
  node_type_id            = "m5.large"  # Tipo de instância AWS mais básico
  autotermination_minutes = 30
  num_workers             = 0  # Single node cluster

  # Em MLSecOps, evitamos permissões excessivas.
  # Se for manipular dados Pix sensíveis,
  # atentar para ACLs e IP restrictions (Databricks Repos).
  # Exemplo de label para auditoria
  custom_tags = {
    "project"     = "mlsecpix"
    "environment" = var.environment
  }
  
  # Configurações específicas do Spark para single node
  spark_conf = {
    "spark.databricks.cluster.profile" : "singleNode"
    "spark.master" : "local[*]"
  }

  # AWS specific
  aws_attributes {
    availability           = "SPOT"
    zone_id                = "auto"
    first_on_demand        = 1
    spot_bid_price_percent = 100
  }
}

############################################################
# RECURSOS: NOTEBOOKS
# Em vez de usar o conteúdo direto, vamos usar um approach alternativo
# com a API REST do Databricks para garantir compatibilidade.
############################################################

resource "databricks_notebook" "bronze_to_silver" {
  path     = "${var.workspace_base_dir}/ETL/bronze_to_silver"
  language = "PYTHON"
  source   = "data-base64:I0BhdXRob3IgUHJvamV0byBNTFNlY1BpeDogRGV0ZWNjYW8gZGUgRnJhdWRlcyBQaXgKZGVmIHByb2Nlc3NfZGF0YSgpOgogICAgIyBFeGVtcGxvIGRlIGNvZGlnbyBQeVNwYXJrIHBhcmEgcHJvY2Vzc2FyIGRhZG9zIEJyb256ZSAtPiBTaWx2ZXIKICAgIHByaW50KCJTaW11bGFuZG8gcHJvY2Vzc2FtZW50byBCcm9uemUgLT4gU2lsdmVyIikKICAgIAogICAgIyBFbSB1bSBwaXBlbGluZSByZWFsLCB0ZXJpYW1vczoKICAgICMgMS4gTGVpdHVyYSBkb3MgZGFkb3MgZGEgY2FtYWRhIEJyb256ZQogICAgIyAyLiBWYWxpZGFjYW8gZSBsaW1wZXphCiAgICAjIDMuIFRyYW5zZm9ybWFjb2VzCiAgICAjIDQuIEVzY3JpdGEgbmEgY2FtYWRhIFNpbHZlcgogICAgcmV0dXJuIFRydWUKCmlmIF9fbmFtZV9fID09ICJfX21haW5fXyI6CiAgICBwcm9jZXNzX2RhdGEoKQ=="
}

resource "databricks_notebook" "silver_to_gold" {
  path     = "${var.workspace_base_dir}/ETL/silver_to_gold"
  language = "PYTHON"
  source   = "data-base64:I0BhdXRob3IgUHJvamV0byBNTFNlY1BpeDogRGV0ZWNjYW8gZGUgRnJhdWRlcyBQaXgKZGVmIHByb2Nlc3NfZGF0YSgpOgogICAgIyBFeGVtcGxvIGRlIGNvZGlnbyBQeVNwYXJrIHBhcmEgcHJvY2Vzc2FyIGRhZG9zIFNpbHZlciAtPiBHb2xkCiAgICBwcmludCgiU2ltdWxhbmRvIHByb2Nlc3NhbWVudG8gU2lsdmVyIC0+IEdvbGQiKQogICAgCiAgICAjIEVtIHVtIHBpcGVsaW5lIHJlYWwsIHRlcmlhbW9zOgogICAgIyAxLiBMZWl0dXJhIGRvcyBkYWRvcyBkYSBjYW1hZGEgU2lsdmVyCiAgICAjIDIuIEFncmVnYWNvZXMgZSB0cmFuc2Zvcm1hY29lcwogICAgIyAzLiBFc2NyaXRhIG5hIGNhbWFkYSBHb2xkCiAgICByZXR1cm4gVHJ1ZQoKaWYgX19uYW1lX18gPT0gIl9fbWFpbl9fIjoKICAgIHByb2Nlc3NfZGF0YSgp"
}

############################################################
# RECURSO: JOB
# Define um job que executa os notebooks. Em ambiente real,
# poderíamos ter tasks paralelas, condicional, triggers
# em cron, etc. Em fase 3 do MLSecPix, orquestra pipelines
# com logs e monitoramento.
############################################################

resource "databricks_job" "mlsecpix_pipeline" {
  name = var.job_name

  # Exemplo: duas tasks que rodam notebooks em sequência.
  task {
    task_key = "bronze_to_silver"
    notebook_task {
      notebook_path = databricks_notebook.bronze_to_silver.path
    }
    existing_cluster_id = databricks_cluster.mlsecpix_job_cluster.id
  }

  task {
    task_key = "silver_to_gold"
    notebook_task {
      notebook_path = databricks_notebook.silver_to_gold.path
    }
    depends_on {
      task_key = "bronze_to_silver"
    }
    existing_cluster_id = databricks_cluster.mlsecpix_job_cluster.id
  }

  # Exemplo de schedule. Em produção, poderíamos
  # usar "cron_schedule" (string "0 3 * * * ?" e etc.).
  schedule {
    quartz_cron_expression = var.job_cron
    timezone_id = "America/Sao_Paulo"
  }

  # Tagging para compliance e auditoria no Databricks
  tags = {
    "project"     = "mlsecpix"
    "environment" = var.environment
    "owner"       = var.job_owner
  }
}
