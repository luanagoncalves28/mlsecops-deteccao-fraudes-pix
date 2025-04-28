# ConfigMap para configuração do Grafana - trigger redeploy grafana services
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

# Service interno para Grafana
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

# Service externo (NodePort) para acessar Grafana externamente
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

# Deployment real para Grafana
resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    annotations = {
      "deployment-version" = "v1" # Controla atualização manual
    }
  }

  lifecycle {
    replace_triggered_by = [
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
        termination_grace_period_seconds = 5

        container {
          name  = "grafana"
          image = "grafana/grafana:10.0.3" # imagem REAL da Grafana estável

          env {
            name  = "GF_SECURITY_ADMIN_USER"
            value = "admin"
          }

          env {
            name  = "GF_SECURITY_ADMIN_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.grafana_credentials.metadata[0].name
                key  = "admin-password"
              }
            }
          }

          volume_mount {
            name       = "grafana-config-volume"
            mount_path = "/etc/grafana/provisioning/datasources"
          }

          port {
            container_port = 3000
            name           = "http"
          }

          resources {
            limits = {
              cpu    = "200m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
          }
        }

        volume {
          name = "grafana-config-volume"

          config_map {
            name = kubernetes_config_map.grafana_config.metadata[0].name
          }
        }
      }
    }
  }
}
