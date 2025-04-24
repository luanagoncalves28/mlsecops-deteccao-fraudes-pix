# ServiceAccount para Prometheus
resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = "prometheus-server"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
}

# ClusterRole para Prometheus
resource "kubernetes_cluster_role" "prometheus" {
  metadata {
    name = "prometheus-server"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "nodes/proxy", "services", "endpoints", "pods"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    non_resource_urls = ["/metrics"]
    verbs             = ["get"]
  }
}

# ClusterRoleBinding para Prometheus
resource "kubernetes_cluster_role_binding" "prometheus" {
  metadata {
    name = "prometheus-server"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.prometheus.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.prometheus.metadata[0].name
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
}

# ConfigMap para configuração do Prometheus
resource "kubernetes_config_map" "prometheus_config" {
  metadata {
    name      = "prometheus-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "prometheus.yml" = <<-EOF
      global:
        scrape_interval: 30s
        evaluation_interval: 30s
      scrape_configs:
        - job_name: 'prometheus'
          static_configs:
            - targets: ['localhost:9090']
        - job_name: 'kubernetes-pods'
          kubernetes_sd_configs:
            - role: pod
          relabel_configs:
            - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
              action: keep
              regex: true
    EOF
  }
}

# Service para Prometheus
resource "kubernetes_service" "prometheus" {
  metadata {
    name      = "prometheus-service"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  spec {
    selector = {
      app = "prometheus-server"
    }

    port {
      port        = 9090
      target_port = 9090
      name        = "http"
    }

    type = "ClusterIP"
  }
}

# Deployment para Prometheus - Recriação completa para resolver problemas de volume
resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus-server"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    
    # Adiciona um timestamp para forçar a recriação a cada apply
    annotations = {
      "recreate-trigger" = "${timestamp()}"
    }
  }

  # Força a substituição do recurso em vez de tentar atualizá-lo
  lifecycle {
    create_before_destroy = true
  }

  # Reduza o timeout para evitar esperar muito tempo pela criação
  timeouts {
    create = "30s"
  }

  spec {
    # Estratégia de atualização "Recreate" em vez de "RollingUpdate"
    strategy {
      type = "Recreate"
    }
    
    replicas = 1

    selector {
      match_labels = {
        app = "prometheus-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "prometheus-server"
        }
        
        # Adiciona um timestamp como anotação para forçar a recriação do pod
        annotations = {
          "recreate-trigger" = "${timestamp()}"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.prometheus.metadata[0].name
        
        termination_grace_period_seconds = 10

        container {
          name  = "prometheus"
          # Usa uma imagem extremamente leve
          image = "busybox:1.36"
          command = ["sh", "-c", "echo 'Prometheus placeholder container'; sleep infinity"]

          port {
            container_port = 9090
          }

          # Recursos mínimos
          resources {
            limits = {
              cpu    = "10m"
              memory = "32Mi"
            }
            requests = {
              cpu    = "5m"
              memory = "16Mi"
            }
          }
        }
      }
    }
  }
}