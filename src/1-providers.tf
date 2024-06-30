provider "aws" {
  region  = local.aws.region
  profile = local.aws.profile
  default_tags {
    tags = {
      service_name = "TBC Portal"
      owner        = "TBC"
      environment  = terraform.workspace
      maintainer   = "Stanimir Simeonov - stanimir.simeonov@skillwork.co.uk"
    }
  }
}
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
provider "kubernetes" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.main.id]
    command     = "aws"
  }
  token = data.aws_eks_cluster_auth.main.token
}


# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
provider "kubectl" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.main.id]
    command     = "aws"
  }
  token = data.aws_eks_cluster_auth.main.token
}

# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
provider "helm" {
 kubernetes {
   host                   = data.aws_eks_cluster.main.endpoint
   cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority.0.data)
   exec {
     api_version = "client.authentication.k8s.io/v1beta1"
     args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.main.id]
     command     = "aws"
   }
   token = data.aws_eks_cluster_auth.main.token
 }
}
