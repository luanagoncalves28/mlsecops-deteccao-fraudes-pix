terraform {
  cloud {
    organization = "tf-mlsecpix-org"
    workspaces {
      name = "mlsecpix-dev"
    }
  }
}