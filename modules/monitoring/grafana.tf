# Deployment para Grafana
resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = merge(var.labels, {
      "app.kubernetes.io/component" = "monitoring"
      "app.kubernetes.io/name"      = "grafana"
      "environment"                 = var.environment
    })
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
        # Adicionando tolerations para garantir que o pod seja agendado mesmo em nós com restrições
        toleration {
          key      = "node.kubernetes.io/not-ready"
          operator = "Exists"
          effect   = "NoExecute"
          toleration_seconds = 300
        }
        
        toleration {
          key      = "node.kubernetes.io/unreachable"
          operator = "Exists"
          effect   = "NoExecute"
          toleration_seconds = 300
        }

        # Reduzindo o tempo de terminação para facilitar a reinicialização
        termination_grace_period_seconds = 30

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
            name  = "GF_PATHS_LOGS"
            value = "/var/log/grafana"
          }

          env {
            name  = "GF_PATHS_PLUGINS"
            value = "/var/lib/grafana/plugins"
          }

          env {
            name  = "GF_PATHS_PROVISIONING"
            value = "/etc/grafana/provisioning"
          }

          # Ajustando limites de recursos para serem mais baixos
          resources {
            limits = {
              cpu    = "200m"
              memory = "200Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "100Mi"
            }
          }

          volume_mount {
            name       = "grafana-data"
            mount_path = "/var/lib/grafana"
          }

          volume_mount {
            name       = "grafana-config"
            mount_path = "/etc/grafana/provisioning/datasources"
            sub_path   = "datasources"
          }

          volume_mount {
            name       = "grafana-config"
            mount_path = "/etc/grafana/provisioning/dashboards"
            sub_path   = "dashboards"
          }

          volume_mount {
            name       = "grafana-dashboards"
            mount_path = "/var/lib/grafana/dashboards"
          }

          # Ajuste nos health checks para serem mais tolerantes
          liveness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 90  # Aumentado para dar mais tempo para inicialização
            timeout_seconds       = 30
            period_seconds        = 20
            success_threshold     = 1
            failure_threshold     = 5
          }

          readiness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 90  # Aumentado para dar mais tempo para inicialização
            timeout_seconds       = 30
            period_seconds        = 20
            success_threshold     = 1
            failure_threshold     = 5
          }
        }

        # Adicionando antiAffinity para evitar múltiplas instâncias no mesmo nó
        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "app"
                    operator = "In"
                    values   = ["grafana"]
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }

        volume {
          name = "grafana-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.grafana.metadata[0].name
          }
        }

        volume {
          name = "grafana-config"
          config_map {
            name = kubernetes_config_map.grafana_config.metadata[0].name
            items {
              key  = "datasources.yaml"
              path = "datasources/datasources.yaml"
            }
            items {
              key  = "dashboards.yaml"
              path = "dashboards/dashboards.yaml"
            }
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