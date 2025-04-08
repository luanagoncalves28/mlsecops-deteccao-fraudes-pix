module "armazenamento" {
  source      = "../../modulos/armazenamento"
  project_id  = var.project_id
  region      = var.region
  environment = "dev"
  labels      = var.labels
}

output "buckets" {
  description = "Nomes dos buckets criados"
  value = {
    bronze = module.armazenamento.bronze_bucket
    silver = module.armazenamento.silver_bucket
    gold   = module.armazenamento.gold_bucket
    models = module.armazenamento.models_bucket
    logs   = module.armazenamento.logs_bucket
  }
}
