provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
  credentials = base64decode(var.gcp_sa_credentials_b64)
}

provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_token
}