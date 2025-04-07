variable "project_id" {
  description = "ID do projeto GCP onde os recursos serão criados"
  type        = string
}

variable "region" {
  description = "Região do GCP onde os recursos serão criados"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zona do GCP dentro da região selecionada"
  type        = string
  default     = "us-central1-a"
}

variable "credentials_file" {
  description = "Caminho para o arquivo de credenciais da conta de serviço"
  type        = string
  default     = "../secrets/forward-walker-456015-g5-9d10f28bcdbb.json"
}

variable "projeto_base" {
  description = "Nome base para os recursos do projeto"
  type        = string
  default     = "mlsecops-pix-fraud"
}

variable "labels_padrao" {
  description = "Labels padrão para todos os recursos"
  type        = map(string)
  default = {
    projeto     = "mlsecops-deteccao-fraudes-pix"
    responsavel = "luana-goncalves"
    ambiente    = "desenvolvimento"
    gerenciado  = "terraform"
    aplicacao   = "deteccao-fraudes-pix"
  }
}
