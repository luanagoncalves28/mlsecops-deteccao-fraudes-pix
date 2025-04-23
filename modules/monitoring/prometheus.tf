# Deployment para Prometheus
resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus-server"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = merge(var.labels, {
      "app.kubernetes.io/component" = "monitoring"
      "app.kubernetes.io/name"      = "prometheus"
      "environment"                 = var.environment
    })
  }

  spec {
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
      }

      spec {
        service_account_name = kubernetes_service_account.prometheus.metadata[0].name
        
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
          name  = "prometheus"
          image = "prom/prometheus:v2.45.0"
          args  = [
            "--config.file=/etc/prometheus/prometheus.yml",
            "--storage.tsdb.path=/prometheus",
            "--storage.tsdb.retention.time=${var.retention_days}d",
            "--web.console.libraries=/etc/prometheus/console_libraries",
            "--web.console.templates=/etc/prometheus/consoles",
            "--web.enable-lifecycle"
          ]

          port {
            container_port = 9090
          }

          volume_mount {
            name       = "prometheus-config"
            mount_path = "/etc/prometheus"
          }

          volume_mount {
            name       = "prometheus-storage"
            mount_path = "/prometheus"
          }

          # Ajustando limites de recursos para serem mais baixos
          resources {
            limits = {
              cpu    = "300m"
              memory = "400Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "200Mi"
            }
          }

          # Ajuste nos health checks para serem mais tolerantes
          liveness_probe {
            http_get {
              path = "/-/healthy"
              port = 9090
            }
            initial_delay_seconds = 60  # Aumentado para dar mais tempo para inicialização
            timeout_seconds       = 30
            period_seconds        = 15
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/-/ready"
              port = 9090
            }
            initial_delay_seconds = 60  # Aumentado para dar mais tempo para inicialização
            timeout_seconds       = 30
            period_seconds        = 15
            success_threshold     = 1
            failure_threshold     = 3
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
                    values   = ["prometheus-server"]
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }

        volume {
          name = "prometheus-config"
          config_map {
            name = kubernetes_config_map.prometheus_config.metadata[0].name
            items {
              key  = "prometheus.yml"
              path = "prometheus.yml"
            }
            items {
              key  = "recording.rules"
              path = "rules/recording.rules"
            }
            items {
              key  = "alerting.rules"
              path = "rules/alerting.rules"
            }
          }
        }

        volume {
          name = "prometheus-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.prometheus.metadata[0].name
          }
        }
      }
    }
  }
}