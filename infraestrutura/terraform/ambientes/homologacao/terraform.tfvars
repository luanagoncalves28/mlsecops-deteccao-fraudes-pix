# Ambiente de Homologação - terraform.tfvars
# Autor: Luana Gonçalves
# Data: Abril 2025

project_id  = "laboratorio_ia_dev"
region      = "us-central1"
zone        = "us-central1-a"
environment = "homologacao"

labels = {
  "project"     = "mlsecops-pix-fraud"
  "environment" = "homologacao"
  "owner"       = "luana-goncalves"
  "created-by"  = "terraform"
  "purpose"     = "deteccao-fraude"
}