# iac/providers.tf  (ou no topo de iac/main.tf)
data "google_client_config" "default" {}

provider "kubernetes" {
  alias                  = "gke"
  host                   = module.gke.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
}