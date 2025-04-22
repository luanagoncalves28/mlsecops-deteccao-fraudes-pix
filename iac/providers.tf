variable "gcp_credentials" {
  type        = string
  description = "Conteúdo JSON da conta de serviço (HCL string)"
  sensitive   = true
}

variable "gcp_project_id"  { type = string }
variable "gcp_region"      { type = string }

###############################################################################
# Provider GOOGLE (default) – usado em todos os módulos
###############################################################################
provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  credentials = var.gcp_credentials           # <-- obrigatório no TFC
}

###############################################################################
# Provider KUBERNETES (alias = gke)  – apontando para o cluster criado
###############################################################################
provider "kubernetes" {
  alias           = "gke"
  host            = module.gke.endpoint
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  token           = module.gke.token
}