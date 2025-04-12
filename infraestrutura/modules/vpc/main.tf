############################################################
# FILE: main.tf
# FOLDER: mlsecpix-infra/modules/vpc/
# DESCRIPTION:
#   Cria a VPC principal e uma sub-rede para a infraestrutura
#   MLSecPix. Inclui ativação de Flow Logs para atender
#   requisitos de auditoria e compliance (BCB nº 403).
#   Contém exemplo de firewall para controle de tráfego.
#
#   Segue Clean Code e boas práticas de MLSecOps: sem
#   hardcode de dados sensíveis, uso de variáveis e
#   comentários contextuais. Em ambiente real, você pode
#   adicionar mais sub-redes ou regras de firewall
#   específicas para cada workload, sempre aplicando
#   o princípio de privilégio mínimo e logs de auditoria.
############################################################

############################################################
# DECLARAÇÃO DE VARIÁVEIS
#   Aqui estamos assumindo que variáveis como project_id,
#   region, vpc_name, subnet_name e cidr_subnet
#   serão recebidas via variables.tf neste módulo 
#   (ou definidas no "main.tf" raiz ao chamar o módulo).
############################################################

# Variáveis mínimas que precisamos, elas podem ser 
# declaradas em vpc/variables.tf (melhor separação),
# mas, para fins demonstrativos, estamos incluindo
# inline para exemplificar.

variable "project_id" {
  type        = string
  description = "ID do projeto GCP onde a VPC será criada."
}

variable "region" {
  type        = string
  description = "Região principal do GCP (ex.: southamerica-east1)."
}

variable "vpc_name" {
  type        = string
  description = "Nome desejado para a rede VPC."
  default     = "mlsecpix-vpc"
}

variable "subnet_name" {
  type        = string
  description = "Nome desejado para a sub-rede."
  default     = "mlsecpix-subnet"
}

variable "cidr_subnet" {
  type        = string
  description = "CIDR da sub-rede (ex.: 10.0.0.0/16)."
  default     = "10.0.0.0/16"
}

variable "enable_flow_logs" {
  type        = bool
  description = "Habilitar ou não Flow Logs para auditoria."
  default     = true
}


############################################################
# RECURSO: REDE VPC
#   Cria uma VPC sem sub-redes automáticas (auto_create_subnetworks = false).
#   Em MLSecOps, recomenda-se habilitar logs de fluxo 
#   (subnet-level) e separar ambientes por sub-redes para 
#   isolar workloads de risco, seguindo princípio de 
#   privilégio mínimo.
############################################################
resource "google_compute_network" "this" {
  name                    = var.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false

  # Em ambientes de produção, possivelmente setar 
  # routing_mode = "GLOBAL", se for preciso multi-região.
  # E associar rotinas de controle (Terraform Cloud ou 
  # Sentinel) para monitorar criações não aprovadas.
}


############################################################
# RECURSO: SUB-REDE
#   Sub-rede configurada com Flow Logs, fundamental
#   para auditorias e conformidade com BCB nº 403,
#   principalmente em sistemas de detecção de fraudes
#   que requerem rastreabilidade e provas de monitoramento
#   do tráfego. 
############################################################
resource "google_compute_subnetwork" "this" {
  name                  = var.subnet_name
  ip_cidr_range         = var.cidr_subnet
  network               = google_compute_network.this.self_link
  region                = var.region
  private_ip_google_access = true

  # Habilitar flow logs, de modo que possamos ter visibilidade 
  # do tráfego de rede, útil para auditorias de segurança 
  # e detecção de atividades suspeitas.
  enable_flow_logs = var.enable_flow_logs

  # Em produção, poderíamos customizar os metadados 
  # do Log Aggregation, como sample_rate, metadata, etc.
}


############################################################
# RECURSO: FIREWALL (EXEMPLO MÍNIMO)
#   Uma regra simples bloqueando todo tráfego de entrada
#   não autorizado. Em ambientes de MLsecOps, criamos 
#   regras específicas para cada serviço, ex.: permitir 
#   22 (SSH) apenas para IPs de Admin, etc.
############################################################
resource "google_compute_firewall" "deny-all-inbound" {
  name      = "${var.vpc_name}-deny-all-inbound"
  network   = google_compute_network.this.self_link
  project   = var.project_id

  # Bloqueia todo o tráfego de entrada, priorizando 
  # a proteção (princípio de "deny by default").
  priority  = 1000
  direction = "INGRESS"

  # target_tags = ["mlsecpix-tag"] # Usar se quiser vincular a instâncias
  # source_ranges = ["0.0.0.0/0"]

  # Nenhum "allow" => tudo é negado
  deny {
    protocol = "all"
  }

  # Em produção, poderia criar outra rule "allow" 
  # para ranges específicos (VPN, bastion).
}


############################################################
# COMENTÁRIO:
#   Se quisermos logs de firewall, podemos ativar 
#   "log_config" neste resource, ex.:
# log_config {
#   metadata = "INCLUDE_ALL_METADATA"
# }
#
# Em um projeto MLSecOps real, registrar metadados
# ajuda a investigar incidentes de fraude e a 
# comprovar boas práticas de segurança (fase 1,2,3).
############################################################
