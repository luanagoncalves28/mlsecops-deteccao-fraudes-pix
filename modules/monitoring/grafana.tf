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

# Deployment para Grafana - Versão simplificada
resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  timeouts {
    create = "3m"
    update = "3m"
    delete = "3m"
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
        container {
          name  = "grafana"
          image = "grafana/grafana:9.5.3"

          port {
            container_port = 3000
            name           = "http"
          }

          env {
            name = "GF_SECURITY_ADMIN_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.grafana_credentials.metadata[0].name
                key  = "admin-user"
              }
            }
          }

          env {
            name = "GF_SECURITY_ADMIN_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.grafana_credentials.metadata[0].name
                key  = "admin-password"
              }
            }
          }

          env {
            name  = "GF_PATHS_DATA"
            value = "/var/lib/grafana"
          }

          env {
            name  = "GF_INSTALL_PLUGINS"
            value = ""
          }

          # Recursos mínimos
          resources {
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
          }

          volume_mount {
            name       = "grafana-storage"
            mount_path = "/var/lib/grafana"
          }

          volume_mount {
            name       = "grafana-config"
            mount_path = "/etc/grafana/provisioning/datasources"
          }

          # Health checks mais simples
          liveness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 5
          }

          # Sem readiness probe para simplificar
        }

        volume {
          name = "grafana-storage"
          empty_dir {}  # Usa armazenamento efêmero em vez de PVC
        }

        volume {
          name = "grafana-config"
          config_map {
            name = kubernetes_config_map.grafana_config.metadata[0].name
          }
        }
      }
    }
  }
}