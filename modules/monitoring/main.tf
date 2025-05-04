# Este arquivo serve como ponto de entrada para o módulo de monitoramento
# Todos os recursos principais são definidos em arquivos específicos
# (namespace.tf, prometheus.tf, grafana.tf, ml_metrics_exporter.tf)

###############################################################################
# BLOCO ÚNICO de required_providers PARA TODO O MÓDULO
###############################################################################
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 1.40.0"
    }
  }
}

###############################################################################
# Locais compartilhados
###############################################################################
locals {
  common_labels = merge(var.labels, {
    "app.kubernetes.io/managed-by" = "terraform"
    "app.kubernetes.io/part-of"    = "mlsecops-monitoring"
    "environment"                  = var.environment
    "project"                      = var.project_id
  })

  # Prefixo padronizado p/ recursos
  resource_prefix = "${var.project_id}-${var.environment}"
}