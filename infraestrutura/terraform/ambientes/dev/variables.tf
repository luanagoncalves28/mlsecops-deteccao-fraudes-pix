variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
  default     = "forward-walker-456015"
}

variable "region" {
  description = "Região principal para recursos do GCP"
  type        = string
  default     = "us-central1"
}

variable "labels" {
  description = "Labels a serem aplicados aos recursos"
  type        = map(string)
  default = {
    ambiente    = "desenvolvimento"
    aplicacao   = "deteccao-fraudes-pix"
    gerenciado  = "terraform"
    projeto     = "mlsecops-deteccao-fraudes-pix"
    responsavel = "luana-goncalves"
  }
}
