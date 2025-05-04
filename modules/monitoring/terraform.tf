############################################################
# ✅ ARQUIVO CRIADO: modules/monitoring/terraform.tf
# Objetivo: Declarar provider grafana no escopo do módulo
#           para evitar erro de resolução no Terraform Cloud
############################################################

terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = ">= 1.40.0"
    }
  }
}