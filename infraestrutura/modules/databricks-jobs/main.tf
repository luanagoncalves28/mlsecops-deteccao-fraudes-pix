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
# Exemplo de criação direta de notebooks com conteúdo simples
# em vez de importar de arquivos.
############################################################

resource "databricks_notebook" "bronze_to_silver" {
  path     = "${var.workspace_base_dir}/ETL/bronze_to_silver"
  language = "PYTHON"
  content  = <<-EOT
    # Notebook: Bronze to Silver
    # Este é um notebook de exemplo criado pelo Terraform.
    # Em um ambiente real, processaria dados da camada Bronze para Silver.
    
    # Exemplo de código PySpark
    from pyspark.sql import functions as F
    
    # Simulação de processamento
    print("Simulando processamento Bronze -> Silver")
    
    # Em um pipeline real, teríamos:
    # 1. Leitura dos dados da camada Bronze
    # 2. Validação e limpeza
    # 3. Transformações
    # 4. Escrita na camada Silver
  EOT
}

resource "databricks_notebook" "silver_to_gold" {
  path     = "${var.workspace_base_dir}/ETL/silver_to_gold"
  language = "PYTHON"
  content  = <<-EOT
    # Notebook: Silver to Gold
    # Este é um notebook de exemplo criado pelo Terraform.
    # Em um ambiente real, processaria dados da camada Silver para Gold.
    
    # Exemplo de código PySpark
    from pyspark.sql import functions as F
    
    # Simulação de processamento
    print("Simulando processamento Silver -> Gold")
    
    # Em um pipeline real, teríamos:
    # 1. Leitura dos dados da camada Silver
    # 2. Agregações e transformações analíticas
    # 3. Escrita na camada Gold para consumo
  EOT
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
