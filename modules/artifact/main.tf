locals {
  repository_name = "${var.repository_id}-${var.environment}"
  
  common_labels = merge(var.labels, {
    "environment" = var.environment
    "managed-by"  = "terraform"
    "product"     = "mlsecpix"
  })
}

# Repositório Artifact Registry para imagens Docker
resource "google_artifact_registry_repository" "docker_repo" {
  provider = google
  
  location      = var.region
  repository_id = local.repository_name
  description   = "Repositório Docker para imagens de ML do MLSecPix - Ambiente ${var.environment}"
  format        = "DOCKER"
  project       = var.project_id
  
  labels = local.common_labels
}

# Service Account para Cloud Build
resource "google_service_account" "cloudbuild_sa" {
  account_id   = "mlsecpix-${var.environment}-build"
  display_name = "MLSecPix Cloud Build Service Account - ${var.environment}"
  project      = var.project_id
}

# Permissões para o Cloud Build acessar o Artifact Registry
resource "google_project_iam_member" "cloudbuild_artifactregistry" {
  project = var.project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

# Permissões para o Cloud Build enviar logs para o Cloud Logging
resource "google_project_iam_member" "cloudbuild_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

# Permissões para o Cloud Build acessar o GKE
resource "google_project_iam_member" "cloudbuild_gke" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

# Permissões para o Cloud Build acessar o Storage
resource "google_project_iam_member" "cloudbuild_storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

# Configurando um trigger básico para Cloud Build (opcional)
resource "google_cloudbuild_trigger" "ml_model_build" {
  project     = var.project_id
  name        = "mlsecpix-${var.environment}-model-build"
  description = "Trigger para build das imagens de ML para MLSecPix"
  
  github {
    owner = "owner" # Ajuste para o proprietário do seu repositório
    name  = "mlsecops-deteccao-fraudes-pix" # Nome do repositório
    
    push {
      branch = "^main$" # Ajuste conforme sua estratégia de branches
    }
  }
  
  included_files = ["models/**"]
  
  filename = "cloudbuild.yaml" # Arquivo com as etapas de build
  
  substitutions = {
    _ENVIRONMENT = var.environment
    _REPOSITORY  = google_artifact_registry_repository.docker_repo.name
    _REGION      = var.region
  }
  
  # Comentado para evitar erros na aplicação inicial
  # Para ativar, descomente e ajuste os valores
  # Você precisará criar o repositório GitHub primeiro
  ignored_files = ["**/*.md", "docs/**"]
  disabled = true
}