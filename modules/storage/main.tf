#############################
#  Data‑lake buckets (B/S/G)
#############################

locals {
  tiers = {
    bronze = var.retention_bronze_days
    silver = var.retention_silver_days
    gold   = var.retention_gold_days
  }
}

resource "google_storage_bucket" "tiers" {
  for_each      = local.tiers
  name          = "mlsecpix-${var.environment}-${each.key}"
  project       = var.project_id
  location      = var.region
  force_destroy = false
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  versioning { enabled = true }

  lifecycle_rule {
    condition { age = each.value }   # retenção por tier
    action    { type = "Delete" }
  }

  labels = merge(var.labels, {
    tier = each.key
    env  = var.environment
  })
}

#############################
#  Buckets de auditoria
#############################

resource "google_storage_bucket" "audit_hot" {
  name          = "mlsecpix-${var.environment}-audit-hot"
  project       = var.project_id
  location      = var.region
  storage_class = "STANDARD"
  uniform_bucket_level_access = true
  versioning { enabled = true }

  lifecycle_rule {
    condition { age = var.retention_audit_hot }
    action    { type = "Delete" }
  }

  labels = merge(var.labels, {
    tier = "audit_hot"
    env  = var.environment
  })
}

resource "google_storage_bucket" "audit_cold" {
  name          = "mlsecpix-${var.environment}-audit-cold"
  project       = var.project_id
  location      = var.region
  storage_class = "ARCHIVE"
  uniform_bucket_level_access = true
  versioning { enabled = true } # pré‑req p/ WORM em prod

  lifecycle_rule {
    condition { age = var.retention_audit_cold }
    action    { type = "Delete" }
  }

  labels = merge(var.labels, {
    tier = "audit_cold"
    env  = var.environment
  })
}