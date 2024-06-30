locals {
  project = {
    name      = "TBC-Application"
    workspace = terraform.workspace
    slug      = "${lower(terraform.workspace)}-tbc-application"
  }
  tags = {
    required = {
      service_name = "TBC Portal"
      owner        = "TBC"
      environment  = terraform.workspace
      maintainer   = "Skillwork & Stanimir Simeonov (stanimir.simeonov@skillwork.co.uk)"
    }
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
}