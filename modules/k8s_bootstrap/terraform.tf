terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.28"
    }
  }
}