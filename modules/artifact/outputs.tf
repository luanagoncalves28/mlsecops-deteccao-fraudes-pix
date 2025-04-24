output "repository_id" {
  description = "ID do repositório Artifact Registry criado"
  value       = google_artifact_registry_repository.docker_repo.repository_id
}

output "repository_url" {
  description = "URL do repositório para uso em comandos docker push"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
}

output "cloudbuild_sa_email" {
  description = "E-mail da conta de serviço do Cloud Build"
  value       = google_service_account.cloudbuild_sa.email
}