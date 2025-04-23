# Este arquivo serve como ponto de entrada para o módulo de monitoramento
# Todos os recursos principais são definidos em outros arquivos mais específicos
# (namespace.tf, prometheus.tf, grafana.tf, ml_metrics_exporter.tf)

# Verificações de versão do provider Kubernetes
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10.0"
    }
  }
}

# Configurações locais utilizadas em vários recursos
locals {
  common_labels = merge(var.labels, {
    "app.kubernetes.io/managed-by" = "terraform"
    "app.kubernetes.io/part-of"    = "mlsecops-monitoring"
    "environment"                  = var.environment
    "project"                      = var.project_id
  })
  
  # Nomes de recursos padronizados
  resource_prefix = "${var.project_id}-${var.environment}"
}