resource "kubernetes_config_map" "alertmanager_config" {
  metadata {
    name      = "alertmanager-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "alertmanager.yml" = <<EOF
global:
  resolve_timeout: 5m
  slack_api_url: 'https://hooks.slack.com/services/PLACEHOLDER/FOR/ACTUAL_TOKEN'

route:
  group_by: ['alertname', 'severity']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 3h
  receiver: 'team-mlops'
  routes:
  - match:
      severity: critical
    receiver: 'team-mlops-pager'
    repeat_interval: 1h
  - match:
      domain: mlsecops
    receiver: 'team-security'

receivers:
- name: 'team-mlops'
  slack_configs:
  - channel: '#mlops-alerts'
    send_resolved: true
    title: "{{ range .Alerts }}{{ .Annotations.summary }}\n{{ end }}"
    text: "{{ range .Alerts }}{{ .Annotations.description }}\n{{ end }}"

- name: 'team-mlops-pager'
  slack_configs:
  - channel: '#mlops-critical'
    send_resolved: true
    title: "🚨 CRÍTICO: {{ range .Alerts }}{{ .Annotations.summary }}\n{{ end }}"
    text: "{{ range .Alerts }}{{ .Annotations.description }}\n{{ end }}"
  email_configs:
  - to: 'oncall-mlops@exemplo.com'
    send_resolved: true

- name: 'team-security'
  slack_configs:
  - channel: '#security-alerts'
    send_resolved: true
    title: "🔒 SEGURANÇA: {{ range .Alerts }}{{ .Annotations.summary }}\n{{ end }}"
    text: "{{ range .Alerts }}{{ .Annotations.description }}\n{{ end }}"
EOF
  }
}

resource "kubernetes_deployment" "alertmanager" {
  metadata {
    name      = "alertmanager"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "alertmanager"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "alertmanager"
      }
    }
    template {
      metadata {
        labels = {
          app = "alertmanager"
        }
      }
      spec {
        container {
          name  = "alertmanager"
          image = "prom/alertmanager:v0.25.0"
          args  = ["--config.file=/etc/alertmanager/alertmanager.yml"]
          port {
            container_port = 9093
            name           = "http"
          }
          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/alertmanager"
          }
          resources {
            limits = {
              cpu    = "100m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "128Mi"
            }
          }
        }
        volume {
          name = "config-volume"
          config_map {
            name = kubernetes_config_map.alertmanager_config.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "alertmanager" {
  metadata {
    name      = "alertmanager"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
  spec {
    selector = {
      app = "alertmanager"
    }
    port {
      port        = 9093
      target_port = 9093
    }
  }
}