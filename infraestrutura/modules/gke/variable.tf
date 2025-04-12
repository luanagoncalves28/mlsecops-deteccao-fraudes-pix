############################################################
# FILE: variables.tf
# FOLDER: mlsecpix-infra/modules/gke/
# DESCRIPTION:
#   Declara as variáveis necessárias para criar e configurar
#   o cluster GKE do projeto MLSecPix, seguindo Clean Code
#   e MLSecOps. Em cenários de detecção de fraudes Pix, 
#   precisamos de logs, monitoramento e compliance
#   com a Resolução BCB nº 403, daí a importância de 
#   rótulos, logs e configurações específicas.
############################################################

############################################################
# PROJETO E REGIÃO GCP
#   Identificam o projeto e a localização onde
#   o cluster GKE será criado.
############################################################
variable "project_id" {
  type        = string
  description = "ID do projeto GCP onde o GKE será criado."
}

variable "region" {
  type        = string
  description = "Região GCP onde o cluster e node pool serão criados."
}

############################################################
# REDE E SUB-REDE (LINKS)
#   Recebemos do módulo VPC (outputs) o self_link da VPC
#   e sub-rede, para conectar o cluster GKE adequadamente.
############################################################
variable "vpc_self_link" {
  type        = string
  description = "Self-link da VPC fornecido pelo módulo VPC."
}

variable "subnet_self_link" {
  type        = string
  description = "Self-link da sub-rede onde o cluster GKE ficará."
}

############################################################
# NOME DO CLUSTER
#   Pode ser customizado se quisermos rodar mais de um 
#   cluster ou diferenciar ambientes (dev, staging, prod).
############################################################
variable "cluster_name" {
  type        = string
  description = "Nome do cluster GKE."
  default     = "mlsecpix-cluster"
}

############################################################
# RELEASE CHANNEL
#   Permite definir se usaremos o canal 'STABLE', 'REGULAR'
#   ou 'RAPID'. Em bancos e compliance, geralmente 
#   preferimos 'REGULAR' ou 'STABLE' para evitar quebras.
############################################################
variable "release_channel" {
  type        = string
  description = "Canal de release do GKE (STABLE, REGULAR, RAPID)."
  default     = "REGULAR"
}

############################################################
# LABELS
#   Ajuda no compliance e rastreabilidade. Ex.: associar
#   'environment=dev', 'team=mlsecops' e etc. 
############################################################
variable "labels" {
  type        = map(string)
  description = "Mapeamento de rótulos para identificar o cluster."
  default     = {
    environment = "dev"
    team        = "mlsecops"
  }
}

############################################################
# NODE POOL (NOME, CONTAGEM E MÁQUINA)
#   Personaliza quantos nós, o tipo da máquina e o nome 
#   do node pool, seguindo as necessidades de ML ou 
#   workloads de detecção de fraudes.
############################################################
variable "node_pool_name" {
  type        = string
  description = "Nome para o node pool GKE."
  default     = "mlsecpix-nodepool"
}

variable "node_count" {
  type        = number
  description = "Número de nós iniciais no node pool."
  default     = 2
}

variable "node_machine_type" {
  type        = string
  description = "Tipo de máquina para os nós GKE (ex.: e2-medium)."
  default     = "e2-medium"
}
