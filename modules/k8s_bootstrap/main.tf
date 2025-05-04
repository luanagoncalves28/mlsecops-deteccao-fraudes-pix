################################################################
# Módulo de bootstrap: cria namespace “ml” + WorkloadIdentity
################################################################
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.27"
    }
  }
}

resource "kubernetes_namespace" "ml" {
  metadata {
    name = "ml"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# ... resto do arquivo permanece igual ...