terraform {
  required_version = ">= 1.6"

  required_providers {
    google     = { source = "hashicorp/google",   version = "~> 5.10" }
    databricks = { source = "databricks/databricks", version = "~> 1.35" }
  }
}