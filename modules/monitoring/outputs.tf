output "prometheus_namespace" {
  description = "Namespace onde o Prometheus e Grafana estão implantados"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "prometheus_service" {
  description = "Nome do serviço do Prometheus"
  value       = kubernetes_service.prometheus-service.metadata[0].name
}

output "grafana_service" {
  description = "Nome do serviço do Grafana"
  value       = kubernetes_service.grafana.metadata[0].name
}

output "grafana_nodeport_url" {
  description = "URL para acessar o Grafana via NodePort (para demonstração)"
  value       = "http://<CLUSTER_IP>:30300"
}