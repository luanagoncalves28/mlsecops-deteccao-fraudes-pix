###############################################################################
# MÓDULO DE MONITORAMENTO – GRAFANA
# ─────────────────────────────────────────────────────────────────────────────
# • Provisiona ConfigMap, Secret, Deployment e Service (LoadBalancer) do Grafana
# • O Service passa a ser LoadBalancer para que o runner do Terraform Cloud
#   consiga chegar ao endpoint.
###############################################################################

#########################
# Configuração do Grafana
#########################
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

#########################
# Credenciais (Secret)
#########################
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

#########################
# Service externo (LoadBalancer)
#########################
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

    type = "LoadBalancer"
  }
}

#########################
# Deployment
#########################
resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    annotations = {
      "deployment-version" = "v1"
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
          image = "grafana/grafana:10.0.3"

          env {
            name  = "GF_SECURITY_ADMIN_USER"
            value = "admin"
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

          # Configurar timeout maior para dashboards complexos
          env {
            name  = "GF_DASHBOARDS_MIN_REFRESH_INTERVAL"
            value = "5s"
          }

          # Aumentar limites para lidar com métricas de ML
          env {
            name  = "GF_SERVER_HTTP_TIMEOUT"
            value = "60"
          }

          volume_mount {
            name       = "grafana-config-volume"
            mount_path = "/etc/grafana/provisioning/datasources"
          }

          volume_mount {
            name       = "grafana-dashboard-provisioning"
            mount_path = "/etc/grafana/provisioning/dashboards"
          }

          volume_mount {
            name       = "grafana-dashboards"
            mount_path = "/var/lib/grafana/dashboards"
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

        volume {
          name = "grafana-dashboard-provisioning"
          config_map {
            name = kubernetes_config_map.grafana_dashboard_provisioning.metadata[0].name
          }
        }

        volume {
          name = "grafana-dashboards"
          config_map {
            name = kubernetes_config_map.grafana_dashboards.metadata[0].name
          }
        }
      }
    }
  }
}