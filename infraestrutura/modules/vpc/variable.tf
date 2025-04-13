############################################################
# FILE: variable.tf
# FOLDER: mlsecpix-infra/modules/vpc/
# DESCRIPTION:
#   Este arquivo define as variáveis necessárias para o
#   módulo de VPC do projeto MLSecPix. Todos os parâmetros
#   relacionados à configuração da rede (como project_id,
#   region, vpc_name, subnet_name, cidr_subnet e enable_flow_logs)
#   estão centralizados aqui, seguindo os princípios de Clean Code,
#   evitando duplicações e facilitando a manutenção, o que é
#   essencial para ambientes MLSecOps e para cumprir requisitos
#   regulatórios.
############################################################

variable "project_id" {
  type        = string
  description = "ID do projeto GCP onde a VPC será criada."
}

variable "region" {
  type        = string
  description = "Região padrão do GCP."
  default     = "southamerica-east1"
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
  description = "Habilitar ou não Flow Logs para auditoria (importante para compliance com BCB nº 403)."
  default     = true
}
