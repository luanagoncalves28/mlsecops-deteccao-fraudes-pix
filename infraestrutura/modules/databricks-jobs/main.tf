terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.7"
    }
  }
}

resource "databricks_cluster" "mlsecpix_job_cluster" {
  cluster_name            = var.cluster_name
  spark_version           = "11.3.x-scala2.12"
  node_type_id            = "m5.large"
  autotermination_minutes = 30
  num_workers             = 0

  custom_tags = {
    "project"     = "mlsecpix"
    "environment" = var.environment
  }
  
  spark_conf = {
    "spark.databricks.cluster.profile" : "singleNode"
    "spark.master" : "local[*]"
  }

  aws_attributes {
    availability           = "SPOT"
    zone_id                = "auto"
    first_on_demand        = 1
    spot_bid_price_percent = 100
  }
}

resource "databricks_notebook" "bronze_to_silver" {
  path     = "${var.workspace_base_dir}/ETL/bronze_to_silver"
  language = "PYTHON"
}

resource "databricks_notebook" "silver_to_gold" {
  path     = "${var.workspace_base_dir}/ETL/silver_to_gold"
  language = "PYTHON"
}

resource "databricks_job" "mlsecpix_pipeline" {
  name = var.job_name

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

  schedule {
    quartz_cron_expression = var.job_cron
    timezone_id = "America/Sao_Paulo"
  }

  tags = {
    "project"     = "mlsecpix"
    "environment" = var.environment
    "owner"       = var.job_owner
  }
}
