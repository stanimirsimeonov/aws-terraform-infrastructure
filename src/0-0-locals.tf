locals {
  project = {
    name      = "TBC-Application"
    workspace = terraform.workspace
    slug      = "${ terraform.workspace}-${var.K8S_NAME}"
    domain =  var.domain
  }
  aws = {
    region  = var.region
    profile = var.profile

    backend = {
      bucket = {
        name = "tbc-application-state"
      }
    }
  }
  k8s = {
    name = var.K8S_NAME
    vpc_cidr = "10.0.0.0/16"
  }
}