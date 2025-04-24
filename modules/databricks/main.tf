locals {
  cluster_name = "${var.databricks_cluster_name}-${var.environment}"
  job_name     = "${var.databricks_job_name}-${var.environment}"
  
  common_tags = merge(var.labels, {
    "environment" = var.environment
    "managed-by"  = "terraform"
    "product"     = "mlsecpix"
  })
  
  # Variável para controlar se os recursos Databricks devem ser criados
  create_databricks_resources = var.enable_databricks_resources
}

# Notebook para testes iniciais
resource "databricks_notebook" "test_notebook" {
  count    = local.create_databricks_resources ? 1 : 0
  path     = "/MLSecPix/teste_conexao_gcp"
  language = "PYTHON"
  
  content_base64 = base64encode(<<-EOT
    # Notebook de Teste - Conexão com GCP
    
    # Importando bibliotecas
    from pyspark.sql import SparkSession
    import matplotlib.pyplot as plt
    import seaborn as sns
    import pandas as pd
    
    # Verificando conexão com o GCS
    bucket_name = "mlsecpix-${var.environment}-bronze"
    test_path = f"gs://{bucket_name}/"
    
    try:
      dbutils.fs.ls(test_path)
      print(f"Conexão com o bucket {bucket_name} estabelecida com sucesso!")
    except Exception as e:
      print(f"Erro ao conectar com o bucket: {str(e)}")
      
    # Testes básicos de SparkSQL
    spark.sql("SELECT 'Databricks funcionando!' AS mensagem").show()
  EOT
  )
}

# Configuração de Secret Scope para guardar credenciais do GCP
resource "databricks_secret_scope" "gcp_scope" {
  count                    = local.create_databricks_resources ? 1 : 0
  name                     = "gcp-credentials"
  initial_manage_principal = "users"
}

# Grupo para Cientistas de Dados
resource "databricks_group" "data_scientists" {
  count        = local.create_databricks_resources ? 1 : 0
  display_name = "MLSecPix Data Scientists"
}

# Grupo para Engenheiros de ML
resource "databricks_group" "ml_engineers" {
  count        = local.create_databricks_resources ? 1 : 0
  display_name = "MLSecPix ML Engineers"
}

# Permissões para o notebook
resource "databricks_permissions" "notebook_usage" {
  count         = local.create_databricks_resources ? 1 : 0
  notebook_path = databricks_notebook.test_notebook[0].path
  
  access_control {
    group_name       = databricks_group.data_scientists[0].display_name
    permission_level = "CAN_EDIT"
  }
  
  access_control {
    group_name       = databricks_group.ml_engineers[0].display_name
    permission_level = "CAN_RUN"
  }
}