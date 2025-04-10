# Ambiente de Produção - terraform.tfvars
# Autor: Luana Gonçalves
# Data: Abril 2025

project_id  = "laboratorio_ia_dev"
region      = "us-central1"
zone        = "us-central1-a"
environment = "producao"

labels = {
  "project"     = "mlsecops-pix-fraud"
  "environment" = "producao"
  "owner"       = "luana-goncalves"
  "created-by"  = "terraform"
  "purpose"     = "deteccao-fraude"
}