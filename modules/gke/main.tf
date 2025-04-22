locals {
  cluster_name = "mlsecpix-${var.environment}-gke"
}

resource "google_container_cluster" "autopilot" {
  name     = local.cluster_name
  project  = var.project_id
  location = var.region

  enable_autopilot = true

  network    = var.network
  subnetwork = var.subnet

  release_channel {
    channel = "STABLE"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  deletion_protection = false   # DEMO
 lifecycle {
    ignore_changes = [initial_node_count]
  }

  resource_labels = merge(var.labels, {
    env     = var.environment
    product = "mlsecpix"
    tier    = "platform"
  })
}