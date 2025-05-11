# Service Account para backups
resource "google_service_account" "backup_sa" {
  account_id   = "mlsecpix-${var.environment}-backup"
  display_name = "MLSecPix Backup Service Account"
  project      = var.project_id
}

# Permissões para ler e escrever no Storage
resource "google_project_iam_member" "backup_sa_storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.backup_sa.email}"
}

# Bucket de destino para backups
resource "google_storage_bucket" "backup_bucket" {
  name          = "mlsecpix-${var.environment}-backups"
  location      = var.region
  storage_class = "STANDARD"
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    condition {
      age = 30  # 30 dias de retenção
    }
    action {
      type = "Delete"
    }
  }
  
  labels = merge(var.labels, {
    purpose = "backup"
    env     = var.environment
  })
  
  uniform_bucket_level_access = true
}

# Bucket para o código fonte da Cloud Function
resource "google_storage_bucket" "function_source" {
  name          = "mlsecpix-${var.environment}-function-src"
  location      = var.region
  force_destroy = true
  
  labels = merge(var.labels, {
    purpose = "function-source"
    env     = var.environment
  })
  
  uniform_bucket_level_access = true
}

# Arquivo ZIP com o código da função
data "archive_file" "backup_function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/function"
  output_path = "${path.module}/function/backup-function.zip"
}

# Upload do código da função para o bucket
resource "google_storage_bucket_object" "backup_function_archive" {
  name   = "backup-function-${data.archive_file.backup_function_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_source.name
  source = data.archive_file.backup_function_zip.output_path
}

# Cloud Function para realização dos backups
resource "google_cloudfunctions_function" "backup_function" {
  name        = "mlsecpix-${var.environment}-backup-function"
  description = "Backup automático dos dados do MLSecPix"
  runtime     = "python39"
  
  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.function_source.name
  source_archive_object = google_storage_bucket_object.backup_function_archive.name
  
  entry_point           = "run_backup"
  timeout               = 540  # 9 minutos (máximo para plano gratuito)
  
  service_account_email = google_service_account.backup_sa.email
  
  environment_variables = {
    SOURCE_BUCKETS = "mlsecpix-${var.environment}-bronze,mlsecpix-${var.environment}-silver,mlsecpix-${var.environment}-gold"
    DEST_BUCKET    = google_storage_bucket.backup_bucket.name
    ENVIRONMENT    = var.environment
  }
  
  # Trigger HTTP (será chamado pelo Cloud Scheduler)
  trigger_http = true
}

# Permissão para invocar a função (necessária para o Cloud Scheduler)
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.backup_function.name
  
  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.backup_sa.email}"
}

# Cloud Scheduler para executar o backup diariamente
resource "google_cloud_scheduler_job" "backup_scheduler" {
  name        = "mlsecpix-${var.environment}-backup-job"
  description = "Agenda de backup diário para dados do MLSecPix"
  schedule    = "0 2 * * *"  # 2 AM todos os dias
  time_zone   = "America/Sao_Paulo"
  
  http_target {
    uri         = google_cloudfunctions_function.backup_function.https_trigger_url
    http_method = "POST"
    
    oidc_token {
      service_account_email = google_service_account.backup_sa.email
    }
  }
}