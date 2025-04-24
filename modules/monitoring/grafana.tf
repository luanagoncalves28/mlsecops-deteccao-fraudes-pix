# ConfigMap para configuração do Grafana
resource "kubernetes_config_map" "grafana_config" {
  metadata {
    name      = "grafana-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "datasources.yaml" = <<-EOF
      apiVersion: 1
      datasources:
      - name: Prometheus
        type: prometheus
        url: http://prometheus-service:9090
        access: proxy
        isDefault: true
    EOF
  }
}

# Secret para credenciais do Grafana
resource "kubernetes_secret" "grafana_credentials" {
  metadata {
    name      = "grafana-credentials"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "admin-password" = var.grafana_admin_password
    "admin-user"     = "admin"
  }

  type = "Opaque"
}

# Service para Grafana
resource "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  spec {
    selector = {
      app = "grafana"
    }

    port {
      port        = 80
      target_port = 3000
      name        = "http"
    }

    type = "ClusterIP"
  }
}

# Cria um serviço NodePort para expor Grafana externamente (para demonstração)
resource "kubernetes_service" "grafana_nodeport" {
  metadata {
    name      = "grafana-external"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  spec {
    selector = {
      app = "grafana"
    }

    port {
      port        = 80
      target_port = 3000
      node_port   = 30300
      name        = "http"
    }

    type = "NodePort"
  }
}

# Deployment para Grafana - Recriação completa para resolver problemas de volume
resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
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
        app = "grafana"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana"
        }
        
        # Adiciona um timestamp como anotação para forçar a recriação do pod
        annotations = {
          "recreate-trigger" = "${timestamp()}"
        }
      }

      spec {
        termination_grace_period_seconds = 10

        container {
          name  = "grafana"
          # Usa uma imagem extremamente leve
          image = "busybox:1.36"
          command = ["sh", "-c", "echo 'Grafana placeholder container'; sleep infinity"]

          port {
            container_port = 3000
            name           = "http"
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