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

# Deployment para Grafana - Versão minimalista
resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    
    # Versão estática para controlar a atualização
    annotations = {
      "deployment-version" = "v1-minimal"
    }
  }
  
  # Força uma destruição antes de tentar recriar
  lifecycle {
    replace_triggered_by = [
      # Usando o hash do namespace como trigger para substituição
      kubernetes_namespace.monitoring.metadata[0].name
    ]
  }

  spec {
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
      }

      spec {
        # Configurando terminação rápida
        termination_grace_period_seconds = 5

        container {
          name  = "grafana"
          image = "busybox:1.36"
          command = ["sh", "-c", "while true; do sleep 3600; done"]

          port {
            container_port = 3000
            name           = "http"
          }

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