##########################################################
# FILE: main.tf
# FOLDER: mlsecpix-infra/modules/gke/
# DESCRIPTION:
# Configura o Google Kubernetes Engine (GKE) para hospedar 
# os componentes do sistema de detecção de fraudes no Pix.
# Este módulo cria um cluster GKE seguindo boas práticas
# de segurança e MLSecOps.
##########################################################

resource "google_container_cluster" "mlsecpix_cluster" {
  name     = "mlsecpix-cluster-${var.environment}"
  location = var.region
  project  = var.project_id
  
  # Remover o node pool padrão que o GKE cria
  remove_default_node_pool = true
  initial_node_count       = 1
  
  # Configurações de rede
  network    = var.vpc_self_link
  subnetwork = var.subnet_self_link
  
  # Ativar IP aliasing para melhor integração com 
  # serviços do GCP e GKE
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "10.4.0.0/16"
    services_ipv4_cidr_block = "10.5.0.0/16"
  }
  
  # Configurações de segurança
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
  
  # Habilitar workload identity para melhor segurança
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # Configurações de logging e monitoramento
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  
  # Configurações de segurança adicionais
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
  
  # Configurações de release channel
  release_channel {
    channel = "REGULAR"
  }

  # Configurar tags
  resource_labels = var.labels
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "mlsecpix-primary-node-pool"
  location   = var.region
  cluster    = google_container_cluster.mlsecpix_cluster.name
  project    = var.project_id
  node_count = var.node_count
  
  node_config {
    preemptible  = var.environment == "prod" ? false : true
    machine_type = var.machine_type
    
    # OAuth scopes para os nodes
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol"
    ]
    
    # Workload identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    
    # Tags e labels
    labels = var.labels
  }
  
  # Configuração de auto scaling
  autoscaling {
    min_node_count = var.min_nodes
    max_node_count = var.max_nodes
  }
  
  # Configuração de atualização automática
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
