############################################################
# FILE: outputs.tf
# FOLDER: mlsecpix-infra/modules/vpc/
# DESCRIPTION:
# Define o que esse módulo de VPC exporta para ser usado
# por outros módulos (GKE, Storage, Databricks) ou pelo
# código principal (main.tf). Dessa forma, quem consumir
# o módulo saberá detalhes como o nome real da VPC,
# self_link, etc.
#
# Em projetos MLSecOps/MLSecPix, é útil expor algumas
# dessas informações para monitoramento, rotulagem
# ou configurações dinâmicas (ex.: GKE precisa saber
# qual VPC e sub-rede associar). Segue princípios de
# Clean Code, cada output é nomeado de forma clara.
############################################################

############################################################
# OUTPUT: VPC NAME
# Retorna o nome efetivo da VPC, útil para logs e
# rotinas de automação. Se quisermos por ex. associar
# outras configurações (firewall, routing) a esse nome,
# podemos recuperar aqui.
############################################################

output "vpc_name" {
  description = "Nome real da rede VPC criada."
  value       = google_compute_network.vpc.name
}

############################################################
# OUTPUT: VPC SELF LINK
# Fornece o self_link do recurso GCP, que pode ser usado
# por outros módulos para referenciá-lo (por ex. um
# peering de rede, ou roteamento customizado).
############################################################

output "vpc_self_link" {
  description = "Self-link da VPC, para referências em módulos externos."
  value       = google_compute_network.vpc.self_link
}

############################################################
# OUTPUT: SUBNET NAME
# Retorna o nome da sub-rede criada, importante se outro
# módulo (por ex. GKE) precisar saber o nome exato da
# sub-rede que está usando.
############################################################

output "subnet_name" {
  description = "Nome da sub-rede criada."
  value       = google_compute_subnetwork.subnet.name
}

############################################################
# OUTPUT: SUBNET SELF LINK
# Para módulos que precisam vincular especificamente
# essa sub-rede (GKE, por ex.), retornamos o link
# completo do recurso.
############################################################

output "subnet_self_link" {
  description = "Self-link da sub-rede, útil para dependências (ex.: GKE)."
  value       = google_compute_subnetwork.subnet.self_link
}
