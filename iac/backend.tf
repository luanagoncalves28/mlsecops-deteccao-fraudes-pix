terraform {
  cloud {
    organization = "tf-org-mlsecpix"
    workspaces {
      name = "mlsecops-deteccao-fraudes-pix"
    }
  }
}