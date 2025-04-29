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

# ConfigMap com a configuração do Prometheus
resource "kubernetes_config_map" "prometheus_config" {
  metadata {
    name      = "prometheus-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "prometheus.yml" = <<-EOT
      global:
        scrape_interval: 15s
        evaluation_interval: 15s

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
    EOT
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

# Deployment para Prometheus com imagem funcional
resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus-server"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    annotations = {
      "deployment-version" = "v2-working"
    }
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
        service_account_name               = kubernetes_service_account.prometheus.metadata[0].name
        termination_grace_period_seconds  = 5

        container {
          name  = "prometheus"
          image = "prom/prometheus:v2.48.1"
          args  = [
            "--config.file=/etc/prometheus/prometheus.yml",
            "--storage.tsdb.path=/prometheus"
          ]

          port {
            container_port = 9090
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/prometheus"
          }

          volume_mount {
            name       = "prometheus-storage"
            mount_path = "/prometheus"
          }
        }

        volume {
          name = "config-volume"

          config_map {
            name = kubernetes_config_map.prometheus_config.metadata[0].name
          }
        }

        volume {
          name = "prometheus-storage"

          empty_dir {}
        }
      }
    }
  }
}