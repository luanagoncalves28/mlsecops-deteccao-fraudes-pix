# Módulo de GKE - main.tf
# Autor: Luana Gonçalves
# Data: Abril 2025

# Cluster GKE para o projeto
resource "google_container_cluster" "primary" {
  name     = "mlsecops-cluster-${var.environment}"
  location = var.zone
  
  # Removemos o node pool default e criamos um personalizado
  remove_default_node_pool = true
  initial_node_count       = 1
  
  # Configurações de rede
  network    = var.network_name
  subnetwork = var.subnetwork_name
  
  # Habilita a API Workload Identity para segurança
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # Configurações de Master authorized networks
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All"
    }
  }
  
  # Configurações de private cluster
  private_cluster_config {
    enable_private_nodes    = false
    enable_private_endpoint = false
  }
  
  # Configurações de logging e monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  
  # Configurações de segurança e autenticação
  release_channel {
    channel = "REGULAR"
  }
}

# Criação de um node pool separado
resource "google_container_node_pool" "primary_nodes" {
  name       = "mlsecops-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes
  
  node_config {
    machine_type = var.machine_type
    disk_size_gb = 50
    
    # Configurações de OAuth scopes
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
    
    # Labels do node
    labels = {
      env = var.environment
    }
    
    # Tags do node
    tags = ["mlsecops", "gke-node", var.environment]
    
    # Configuração de Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
  
  # Configurações de auto-scaling
  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }
  
  # Configurações de gerenciamento
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}