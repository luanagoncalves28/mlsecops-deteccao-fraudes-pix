############################################################
# FILE: main.tf
# FOLDER: mlsecpix-infra/modules/gke/
# DESCRIPTION:
#   Cria um cluster GKE e um node pool, integrando-se a 
#   práticas de MLSecOps. Suporta auditoria, rótulos e 
#   configurações de segurança (RBAC, Flow Logs na VPC).
#   Em ambientes de detecção de fraudes Pix, rodar cargas
#   de trabalho no GKE com logs e restrições de acesso 
#   atende requisitos regulatórios (BCB nº 403).
#
#   Em produção, poderíamos habilitar Private Nodes, 
#   Master Authorized Networks ou Identity-Aware Proxy.
#   Aqui ilustramos um fluxo essencial, com a mentalidade
#   de Clean Code e compliance. 
############################################################

############################################################
# RECURSOS USADOS:
#   - google_container_cluster
#   - google_container_node_pool
#
# VARIÁVEIS:
#   - Recebidas via variables.tf (project_id, region, 
#     vpc_self_link, subnet_self_link, etc.)
#   - Cada parâmetro que possa variar é declarado em
#     variables.tf, para evitar duplicação e facilitar
#     manutenção. 
############################################################


# Cria o cluster GKE principal, sem node pool padrão,
# para termos controle total (remoção do default pool).
resource "google_container_cluster" "this" {
  name                = var.cluster_name
  project             = var.project_id
  location            = var.region
  network             = var.vpc_self_link
  subnetwork          = var.subnet_self_link
  remove_default_node_pool = true

  # Opcional: canal de release. Em produção, "REGULAR" 
  # ou "STABLE" são comuns. "RAPID" é mais arriscado.
  release_channel {
    channel = var.release_channel
  }

  # Exemplo: habilitar logging para auditoria MLSecOps.
  # "system_components" e "workloads" podem ser configurados
  # conforme necessidade.
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  # Monitoramento também é vital para compliance e 
  # observabilidade.
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  # Rótulos para fins de compliance, rastreabilidade 
  # e custo. 
  resource_labels = var.labels

  # Em produção MLSecOps, ativar private cluster, 
  # mas isso exige configurações de IPs extras.
  # private_cluster_config {
  #   enable_private_endpoint = true
  #   enable_private_nodes    = true
  #   master_ipv4_cidr_block = "172.16.0.0/28"
  # }
}

# Node pool separado para garantir escalabilidade 
# e configurações específicas. Em ambientes de ML, 
# podemos escolher máquinas mais robustas (GPU, etc).
resource "google_container_node_pool" "node_pool" {
  name       = var.node_pool_name
  project    = var.project_id
  location   = var.region
  cluster    = google_container_cluster.this.name
  node_count = var.node_count

  node_config {
    machine_type = var.node_machine_type
    labels       = var.labels
    # Podem ser definidas scopes, service_account, 
    # e etc. Em cenários MLSecOps, cuidado com 
    # permissões de service_account.
  }

  # Se quisermos autoescalamento:
  # autoscaling {
  #   min_node_count = 1
  #   max_node_count = 5
  # }

  # Logging de eventos no pool, dependendo do nível
  # de auditoria exigido
  upgrade_settings {
    # Em um cluster real, definimos max_surge e 
    # max_unavailable para upgrades controlados.
    max_surge       = 1
    max_unavailable = 0
  }
}
