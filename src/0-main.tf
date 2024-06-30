terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.3"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.7.1" //use this because of issues
    }
  }
  # ----------------------------------------------------------------------------------------------------------------------

  # ----------------------------------------------------------------------------------------------------------------------
  backend "s3" {
    bucket         = "tbc-application-state"
    profile        = "tbc-profile"
    key            = "state/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    kms_key_id     = "alias/state-bucket-key"
    dynamodb_table = "terraform-state"
  }

}