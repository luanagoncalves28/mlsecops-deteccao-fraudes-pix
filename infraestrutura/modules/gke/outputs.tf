############################################################
# FILE: outputs.tf
# FOLDER: mlsecpix-infra/modules/gke/
# DESCRIPTION:
#   Expõe saídas importantes do cluster GKE (nome,
#   endpoint, etc.) e do node pool, de modo que 
#   outros módulos ou o arquivo "main.tf" raiz possam
#   consumi-las. Segue práticas de Clean Code e MLSecOps.
#
#   Em ambientes de detecção de fraudes Pix, podemos 
#   precisar integrar esse cluster a pipelines, gerar 
#   dashboards de compliance ou logs avançados. Esses 
#   outputs permitem verificar a topologia e realizar 
#   automações adicionais com foco regulatório.
############################################################

############################################################
# OUTPUT: CLUSTER NAME
#   Nome real do cluster criado. Embora possamos definir
#   um default, o valor final é retornado para 
#   rastreabilidade e para uso em scripts de automação.
############################################################
output "cluster_name" {
  description = "Nome do cluster GKE criado."
  value       = google_container_cluster.this.name
}

############################################################
# OUTPUT: CLUSTER ENDPOINT
#   Endereço do servidor de controle (control plane) do GKE.
#   Em cenários MLSecOps, podemos usá-lo para configurar 
#   segurança extra, ou integrá-lo a pipelines de CI/CD 
#   que executem kubectl.
############################################################
output "cluster_endpoint" {
  description = "Endpoint do cluster GKE (endereço do control plane)."
  value       = google_container_cluster.this.endpoint
}

############################################################
# OUTPUT: CLUSTER SELF LINK
#   Útil caso outros módulos precisem referenciar 
#   diretamente o cluster em alguma configuração avançada
#   de IAM ou VPC Service Controls.
############################################################
output "cluster_self_link" {
  description = "Self-link do recurso do cluster GKE."
  value       = google_container_cluster.this.self_link
}

############################################################
# OUTPUT: NODE POOL NAME
#   Em ambientes com diversos node pools, pode ser que 
#   um pipeline precise saber o nome exato. Se tivermos 
#   jobs de ML distintos, usaríamos naming convention e 
#   registraríamos esse output para orquestração.
############################################################
output "node_pool_name" {
  description = "Nome do node pool GKE."
  value       = google_container_node_pool.node_pool.name
}

############################################################
# OUTPUT: NODE POOL ID
#   Em caso de automações específicas de escalonamento, 
#   rotação de nós, etc., o ID exato do node pool pode 
#   ser requerido.
############################################################
output "node_pool_id" {
  description = "ID do node pool GKE, útil para manipulações avançadas."
  value       = google_container_node_pool.node_pool.id
}
