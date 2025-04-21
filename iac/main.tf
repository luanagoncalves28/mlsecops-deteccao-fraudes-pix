module "vpc" {
  source       = "../modules/vpc"

  project_id   = var.gcp_project_id
  region       = var.gcp_region
  network_name = "mlsecpix-vpc"
  subnet_cidr  = "10.0.0.0/16"
  environment  = var.environment
}

# opcional: bucket canário permanece
resource "google_storage_bucket" "tf_canary" {
  name                        = "mlsecpix-tf-canary-${var.environment}"
  location                    = var.gcp_region
  uniform_bucket_level_access = true
  force_destroy               = true
}