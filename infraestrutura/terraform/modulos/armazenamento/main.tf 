# Módulo de Armazenamento - main.tf
# Autor: Luana Gonçalves
# Data: Abril 2025

# Buckets para armazenamento de dados
resource "google_storage_bucket" "buckets" {
  count = 3
  
  name          = "mlsecops-pix-${var.environment}-${count.index}"
  location      = var.region
  storage_class = "STANDARD"
  
  uniform_bucket_level_access = true
  force_destroy               = true
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }
  
  labels = var.labels
}

# Configuração de IAM para os buckets
resource "google_storage_bucket_iam_binding" "bucket_iam" {
  count  = length(google_storage_bucket.buckets)
  bucket = google_storage_bucket.buckets[count.index].name
  role   = "roles/storage.objectViewer"
  
  members = [
    "serviceAccount:${var.project_id}@appspot.gserviceaccount.com",
  ]
}