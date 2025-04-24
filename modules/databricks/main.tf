locals {
  cluster_name = "${var.databricks_cluster_name}-${var.environment}"
  job_name     = "${var.databricks_job_name}-${var.environment}"
  
  common_tags = merge(var.labels, {
    "environment" = var.environment
    "managed-by"  = "terraform"
    "product"     = "mlsecpix"
  })
}

# Configuração do provider Databricks
provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_token
}

# Cluster para processamento de dados e desenvolvimento
resource "databricks_cluster" "data_processing" {
  cluster_name            = local.cluster_name
  spark_version           = var.spark_version
  node_type_id            = var.node_type_id
  autotermination_minutes = 20  # Encerra após 20 minutos de inatividade

  autoscale {
    min_workers = var.autoscale_min_workers
    max_workers = var.autoscale_max_workers
  }

  spark_conf = {
    "spark.databricks.delta.preview.enabled" = "true"
    "spark.databricks.io.cache.enabled"      = "true"
  }

  custom_tags = local.common_tags
}

# Pasta para notebooks
resource "databricks_notebook_directory" "mlsecpix_notebooks" {
  path = "/MLSecPix"
}

# Notebook para testes iniciais
resource "databricks_notebook" "test_notebook" {
  path     = "${databricks_notebook_directory.mlsecpix_notebooks.path}/teste_conexao_gcp"
  language = "PYTHON"
  
  content_base64 = base64encode(<<-EOT
    # Notebook de Teste - Conexão com GCP
    
    # Importando bibliotecas
    from pyspark.sql import SparkSession
    import matplotlib.pyplot as plt
    import seaborn as sns
    import pandas as pd
    
    # Verificando conexão com o GCS
    # Substitua pelo bucket real do seu projeto
    bucket_name = "mlsecpix-${var.environment}-bronze"
    test_path = f"gs://{bucket_name}/"
    
    try:
      dbutils.fs.ls(test_path)
      print(f"✅ Conexão com o bucket {bucket_name} estabelecida com sucesso!")
    except Exception as e:
      print(f"❌ Erro ao conectar com o bucket: {str(e)}")
      
    # Testes básicos de SparkSQL
    spark.sql("SELECT 'Databricks funcionando!' AS mensagem").show()
    
    # NOTA: Este notebook é apenas para testes iniciais.
    # Os notebooks reais de processamento de dados e ML serão desenvolvidos pela equipe de Data Science.
  EOT
  )
}

# Exemplo de Job para treinamento (ativado manualmente no início)
resource "databricks_job" "training_job" {
  name = local.job_name
  
  new_cluster {
    spark_version = var.spark_version
    node_type_id  = var.node_type_id
    num_workers   = 2
    # Nota: autotermination_minutes não é um parâmetro válido para new_cluster no contexto de jobs
  }
  
  # Usando task para o notebook, não notebook_task
  task {
    task_key = "training_task"
    notebook_task {
      notebook_path = databricks_notebook.test_notebook.path
    }
  }
  
  schedule {
    quartz_cron_expression = "0 0 0 ? * MON-FRI"  # Segunda a sexta à meia-noite
    timezone_id            = "America/Sao_Paulo"
  }
  
  email_notifications {
    on_success = []
    on_failure = []
  }
  
  # Usado o formato correto para pausar o job
  format = "MULTI_TASK"
  
  max_concurrent_runs = 1
  
  tags = local.common_tags
}

# Configuração de Secret Scope para guardar credenciais do GCP
resource "databricks_secret_scope" "gcp_scope" {
  name                     = "gcp-credentials"
  initial_manage_principal = "users"
}

# Grupo para Cientistas de Dados
resource "databricks_group" "data_scientists" {
  display_name = "MLSecPix Data Scientists"
}

# Grupo para Engenheiros de ML
resource "databricks_group" "ml_engineers" {
  display_name = "MLSecPix ML Engineers"
}

# Permissões para o workspace
resource "databricks_permissions" "notebook_usage_perm" {
  notebook_path = databricks_notebook.test_notebook.path
  
  access_control {
    group_name       = databricks_group.data_scientists.display_name
    permission_level = "CAN_EDIT"
  }
  
  access_control {
    group_name       = databricks_group.ml_engineers.display_name
    permission_level = "CAN_RUN"
  }
}