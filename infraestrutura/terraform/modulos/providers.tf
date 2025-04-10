# Providers compartilhados
# Autor: Luana Gonçalves
# Data: Abril 2025

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.11.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.11.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24.0"
    }
  }
}