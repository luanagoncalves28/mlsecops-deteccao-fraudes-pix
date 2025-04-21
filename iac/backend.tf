terraform {
  cloud {
    organization = "SUBSTITUA_PELA_SUA_ORG_TFC"
    workspaces {
      name = "mlsecpix-dev"
    }
  }
}