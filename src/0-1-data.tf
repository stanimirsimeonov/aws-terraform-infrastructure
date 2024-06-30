data "aws_availability_zones" "available" {}

# ----------------------------------------------------------------------------------------------------------------------
# Getting the the region of the deployed ELS Cluster
# ----------------------------------------------------------------------------------------------------------------------
data "aws_region" "current" {}


data "aws_caller_identity" "current" {}

# ----------------------------------------------------------------------------------------------------------------------
# Getting the TLS certificate of the deployed cluster
# ----------------------------------------------------------------------------------------------------------------------

data "tls_certificate" "eks" {
  url        = aws_eks_cluster.main.identity[0].oidc[0].issuer
#  depends_on = [
#    aws_eks_cluster.main
#  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Getting the main KMS key through the alias dropped
# ----------------------------------------------------------------------------------------------------------------------

data "aws_kms_alias" "ssm" {
  name = "alias/aws/ssm"
}

# ----------------------------------------------------------------------------------------------------------------------
# Getting the possibility to extract the EKS token for login while using providers such as Kubernetes, Helm or Kubectl
# ----------------------------------------------------------------------------------------------------------------------
data "aws_eks_cluster_auth" "main" {
  name       = aws_eks_cluster.main.id
#  depends_on = [aws_eks_cluster.main]
}


# ----------------------------------------------------------------------------------------------------------------------
# Getting the information according the deployed cluster and use it where it is needed
# ----------------------------------------------------------------------------------------------------------------------
data "aws_eks_cluster" "main" {
  name       = aws_eks_cluster.main.id
#  depends_on = [
#    aws_eks_cluster.main
#  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Getting the information according the hosting zone we are using to deploy the certain application
# ----------------------------------------------------------------------------------------------------------------------
data "aws_route53_zone" "main" {
  name         = local.project.domain
  private_zone = false
}


