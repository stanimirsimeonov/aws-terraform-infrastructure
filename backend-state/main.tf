terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket         = "tbc-application-state"
    profile        = "tbc-profile"
    key            = "state/backend/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    kms_key_id     = "alias/state-bucket-key"
    dynamodb_table = "terraform-state"
  }
}

provider "aws" {
  region  = local.aws.region
  profile = local.aws.profile
}