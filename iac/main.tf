resource "google_storage_bucket" "tf_canary" {
  name                        = "mlsecpix-tf-canary-${var.environment}"
  location                    = var.gcp_region
  uniform_bucket_level_access = true
  force_destroy               = true
}