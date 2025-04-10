# Variáveis para o ambiente de desenvolvimento
# Autor: Luana Gonçalves
# Data: Abril 2025

variable "project_id" {
  description = "ID do projeto no Google Cloud Platform"
  type        = string
  default     = "fintech-pix-novo"  # Atualizado para o projeto correto
}

variable "region" {
  description = "Região do GCP para os recursos"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zona do GCP para recursos zonais"
  type        = string
  default     = "us-central1-a"
}

variable "environment" {
  description = "Ambiente (dev, homologacao, producao)"
  type        = string
  default     = "dev"
}

variable "labels" {
  description = "Labels a serem aplicados a todos os recursos"
  type        = map(string)
  default = {
    "created-by" = "terraform"
    "environment" = "dev"
    "project"    = "mlsecops-pix-fraud"
    "purpose"    = "deteccao-fraude"
    "owner"      = "luana-goncalves"
  }
}

# Definições para recursos de rede
variable "network_name" {
  description = "Nome da rede VPC"
  type        = string
  default     = "mlsecops-vpc-dev"
}

variable "subnet_name" {
  description = "Nome da subnet"
  type        = string
  default     = "mlsecops-subnet-dev"
}

variable "subnet_cidr" {
  description = "CIDR da subnet"
  type        = string
  default     = "10.0.0.0/20"
}

# Definições para GKE
variable "cluster_name" {
  description = "Nome do cluster GKE"
  type        = string
  default     = "mlsecops-cluster-dev"
}

variable "node_pool_name" {
  description = "Nome do node pool do GKE"
  type        = string
  default     = "mlsecops-node-pool"
}

variable "machine_type" {
  description = "Tipo de máquina para os nós do GKE"
  type        = string
  default     = "e2-standard-2"
}

variable "min_node_count" {
  description = "Número mínimo de nós no cluster"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Número máximo de nós no cluster"
  type        = number
  default     = 3
}