# ConfigMap para configuração do Grafana
resource "kubernetes_config_map" "grafana_config" {
  metadata {
    name      = "grafana-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = merge(var.labels, {
      "app.kubernetes.io/component" = "monitoring"
      "app.kubernetes.io/name"      = "grafana"
      "environment"                 = var.environment
    })
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
        editable: false
    EOF

    "dashboards.yaml" = <<-EOF
      apiVersion: 1
      providers:
      - name: 'default'
        orgId: 1
        folder: ''
        type: file
        disableDeletion: false
        editable: true
        options:
          path: /var/lib/grafana/dashboards
    EOF
  }
}

# ConfigMap para dashboards do Grafana
resource "kubernetes_config_map" "grafana_dashboards" {
  metadata {
    name      = "grafana-dashboards"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = merge(var.labels, {
      "app.kubernetes.io/component" = "monitoring"
      "app.kubernetes.io/name"      = "grafana"
      "environment"                 = var.environment
    })
  }

  data = {
    "ml-model-overview.json" = <<-EOF
      {
        "annotations": {
          "list": []
        },
        "editable": true,
        "gnetId": null,
        "graphTooltip": 0,
        "hideControls": false,
        "links": [],
        "refresh": "10s",
        "rows": [
          {
            "collapse": false,
            "height": "250px",
            "panels": [
              {
                "aliasColors": {},
                "bars": false,
                "dashLength": 10,
                "dashes": false,
                "datasource": "Prometheus",
                "fill": 1,
                "id": 1,
                "legend": {
                  "avg": false,
                  "current": false,
                  "max": false,
                  "min": false,
                  "show": true,
                  "total": false,
                  "values": false
                },
                "lines": true,
                "linewidth": 1,
                "links": [],
                "nullPointMode": "null",
                "percentage": false,
                "pointradius": 5,
                "points": false,
                "renderer": "flot",
                "seriesOverrides": [],
                "spaceLength": 10,
                "span": 6,
                "stack": false,
                "steppedLine": false,
                "targets": [
                  {
                    "expr": "ml_model_prediction_latency_seconds",
                    "format": "time_series",
                    "intervalFactor": 2,
                    "legendFormat": "{{model_version}}",
                    "refId": "A"
                  }
                ],
                "thresholds": [],
                "timeFrom": null,
                "timeShift": null,
                "title": "Prediction Latency",
                "tooltip": {
                  "shared": true,
                  "sort": 0,
                  "value_type": "individual"
                },
                "type": "graph",
                "xaxis": {
                  "buckets": null,
                  "mode": "time",
                  "name": null,
                  "show": true,
                  "values": []
                },
                "yaxes": [
                  {
                    "format": "s",
                    "label": null,
                    "logBase": 1,
                    "max": null,
                    "min": null,
                    "show": true
                  },
                  {
                    "format": "short",
                    "label": null,
                    "logBase": 1,
                    "max": null,
                    "min": null,
                    "show": true
                  }
                ]
              },
              {
                "aliasColors": {},
                "bars": false,
                "dashLength": 10,
                "dashes": false,
                "datasource": "Prometheus",
                "fill": 1,
                "id": 2,
                "legend": {
                  "avg": false,
                  "current": false,
                  "max": false,
                  "min": false,
                  "show": true,
                  "total": false,
                  "values": false
                },
                "lines": true,
                "linewidth": 1,
                "links": [],
                "nullPointMode": "null",
                "percentage": false,
                "pointradius": 5,
                "points": false,
                "renderer": "flot",
                "seriesOverrides": [],
                "spaceLength": 10,
                "span": 6,
                "stack": false,
                "steppedLine": false,
                "targets": [
                  {
                    "expr": "rate(ml_model_prediction_errors_total[5m])",
                    "format": "time_series",
                    "intervalFactor": 2,
                    "legendFormat": "{{model_version}} - {{error_type}}",
                    "refId": "A"
                  }
                ],
                "thresholds": [],
                "timeFrom": null,
                "timeShift": null,
                "title": "Prediction Errors",
                "tooltip": {
                  "shared": true,
                  "sort": 0,
                  "value_type": "individual"
                },
                "type": "graph",
                "xaxis": {
                  "buckets": null,
                  "mode": "time",
                  "name": null,
                  "show": true,
                  "values": []
                },
                "yaxes": [
                  {
                    "format": "short",
                    "label": null,
                    "logBase": 1,
                    "max": null,
                    "min": null,
                    "show": true
                  },
                  {
                    "format": "short",
                    "label": null,
                    "logBase": 1,
                    "max": null,
                    "min": null,
                    "show": true
                  }
                ]
              }
            ],
            "repeat": null,
            "repeatIteration": null,
            "repeatRowId": null,
            "showTitle": false,
            "title": "Dashboard Row",
            "titleSize": "h6"
          },
          {
            "collapse": false,
            "height": 250,
            "panels": [
              {
                "aliasColors": {},
                "bars": false,
                "dashLength": 10,
                "dashes": false,
                "datasource": "Prometheus",
                "fill": 1,
                "id": 3,
                "legend": {
                  "avg": false,
                  "current": false,
                  "max": false,
                  "min": false,
                  "show": true,
                  "total": false,
                  "values": false
                },
                "lines": true,
                "linewidth": 1,
                "links": [],
                "nullPointMode": "null",
                "percentage": false,
                "pointradius": 5,
                "points": false,
                "renderer": "flot",
                "seriesOverrides": [],
                "spaceLength": 10,
                "span": 6,
                "stack": false,
                "steppedLine": false,
                "targets": [
                  {
                    "expr": "ml_model_feature_drift_score",
                    "format": "time_series",
                    "intervalFactor": 2,
                    "legendFormat": "{{feature_name}}",
                    "refId": "A"
                  }
                ],
                "thresholds": [
                  {
                    "colorMode": "critical",
                    "fill": true,
                    "line": true,
                    "op": "gt",
                    "value": 0.1
                  }
                ],
                "timeFrom": null,
                "timeShift": null,
                "title": "Feature Drift Score",
                "tooltip": {
                  "shared": true,
                  "sort": 0,
                  "value_type": "individual"
                },
                "type": "graph",
                "xaxis": {
                  "buckets": null,
                  "mode": "time",
                  "name": null,
                  "show": true,
                  "values": []
                },
                "yaxes": [
                  {
                    "format": "short",
                    "label": null,
                    "logBase": 1,
                    "max": null,
                    "min": "0",
                    "show": true
                  },
                  {
                    "format": "short",
                    "label": null,
                    "logBase": 1,
                    "max": null,
                    "min": null,
                    "show": true
                  }
                ]
              },
              {
                "aliasColors": {},
                "bars": false,
                "dashLength": 10,
                "dashes": false,
                "datasource": "Prometheus",
                "fill": 1,
                "id": 4,
                "legend": {
                  "avg": false,
                  "current": false,
                  "max": false,
                  "min": false,
                  "show": true,
                  "total": false,
                  "values": false
                },
                "lines": true,
                "linewidth": 1,
                "links": [],
                "nullPointMode": "null",
                "percentage": false,
                "pointradius": 5,
                "points": false,
                "renderer": "flot",
                "seriesOverrides": [],
                "spaceLength": 10,
                "span": 6,
                "stack": false,
                "steppedLine": false,
                "targets": [
                  {
                    "expr": "rate(ml_model_predictions_total[5m])",
                    "format": "time_series",
                    "intervalFactor": 2,
                    "legendFormat": "{{model_version}}",
                    "refId": "A"
                  }
                ],
                "thresholds": [],
                "timeFrom": null,
                "timeShift": null,
                "title": "Prediction Throughput",
                "tooltip": {
                  "shared": true,
                  "sort": 0,
                  "value_type": "individual"
                },
                "type": "graph",
                "xaxis": {
                  "buckets": null,
                  "mode": "time",
                  "name": null,
                  "show": true,
                  "values": []
                },
                "yaxes": [
                  {
                    "format": "short",
                    "label": "predictions/sec",
                    "logBase": 1,
                    "max": null,
                    "min": null,
                    "show": true
                  },
                  {
                    "format": "short",
                    "label": null,
                    "logBase": 1,
                    "max": null,
                    "min": null,
                    "show": true
                  }
                ]
              }
            ],
            "repeat": null,
            "repeatIteration": null,
            "repeatRowId": null,
            "showTitle": false,
            "title": "Dashboard Row",
            "titleSize": "h6"
          }
        ],
        "schemaVersion": 14,
        "style": "dark",
        "tags": [
          "mlops",
          "fraud-detection"
        ],
        "templating": {
          "list": []
        },
        "time": {
          "from": "now-6h",
          "to": "now"
        },
        "timepicker": {
          "refresh_intervals": [
            "5s",
            "10s",
            "30s",
            "1m",
            "5m",
            "15m",
            "30m",
            "1h",
            "2h",
            "1d"
          ],
          "time_options": [
            "5m",
            "15m",
            "1h",
            "6h",
            "12h",
            "24h",
            "2d",
            "7d",
            "30d"
          ]
        },
        "timezone": "browser",
        "title": "ML Model Overview",
        "version": 1
      }
    EOF
  }
}

# Secret para credenciais do Grafana
resource "kubernetes_secret" "grafana_credentials" {
  metadata {
    name      = "grafana-credentials"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = merge(var.labels, {
      "app.kubernetes.io/component" = "monitoring"
      "app.kubernetes.io/name"      = "grafana"
      "environment"                 = var.environment
    })
  }

  data = {
    "admin-password" = var.grafana_admin_password
    "admin-user"     = "admin"
  }

  type = "Opaque"
}

# PersistentVolumeClaim para Grafana
resource "kubernetes_persistent_volume_claim" "grafana" {
  metadata {
    name      = "grafana-data"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = merge(var.labels, {
      "app.kubernetes.io/component" = "monitoring"
      "app.kubernetes.io/name"      = "grafana"
      "environment"                 = var.environment
    })
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
    storage_class_name = "standard"
  }
}

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

# Service para Grafana
resource "kubernetes_service" "grafana" {
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
    labels = merge(var.labels, {
      "app.kubernetes.io/component" = "monitoring"
      "app.kubernetes.io/name"      = "grafana"
      "environment"                 = var.environment
    })
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