resource "kubernetes_deployment" "prometheus_pushgateway" {
  metadata {
    name      = "prometheus-pushgateway"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "prometheus-pushgateway"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "prometheus-pushgateway"
      }
    }
    template {
      metadata {
        labels = {
          app = "prometheus-pushgateway"
        }
      }
      spec {
        container {
          name  = "pushgateway"
          image = "prom/pushgateway:v1.6.0"
          port {
            container_port = 9091
            name           = "http"
          }
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
        }
      }
    }
  }
}

resource "kubernetes_service" "prometheus_pushgateway" {
  metadata {
    name      = "prometheus-pushgateway"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "prometheus-pushgateway"
    }
  }
  spec {
    selector = {
      app = "prometheus-pushgateway"
    }
    port {
      port        = 9091
      target_port = 9091
      name        = "http"
    }
  }
}