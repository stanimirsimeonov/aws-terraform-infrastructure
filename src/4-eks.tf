# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "aws_eks_cluster" "main" {
  name     = local.project.slug
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids = concat(
      aws_subnet.public.*.id,
      aws_subnet.privates.*.id
    )
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role.eks
  ]

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.main.arn
    }
  }

}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}


resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "general"
  node_role_arn   = aws_iam_role.eks-node.arn

  subnet_ids     = aws_subnet.privates.*.id
  instance_types = [
    "t3a.xlarge",
    "t2.xlarge",
    "m5.xlarge",
    "m5.2xlarge",
    "m6i.2xlarge",
    "m5.2xlarge",
    "t3.small",
    "t3.medium",
    "t2.small",
    "t2.medium",
    "t2.large",
    "t2.xlarge",
    "t3.large"
  ]
  capacity_type  = "SPOT"

  scaling_config {
    desired_size = 3
    max_size     = 10
    min_size     = 1
  }

  update_config {
    max_unavailable_percentage = 1
  }

  lifecycle {
    ignore_changes = [
      scaling_config.0.desired_size,
      instance_types
    ]
  }


  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluser-node-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.cluser-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.cluser-node-AmazonEKSWorkerNodePolicy,
  ]

  # taint {
  #   key    = "team"
  #   value  = "devops"
  #   effect = "NO_SCHEDULE"
  # }

  # launch_template {
  #   name    = aws_launch_template.eks-with-disks.name
  #   version = aws_launch_template.eks-with-disks.latest_version
  # }

}


# resource "aws_launch_template" "eks-with-disks" {
#   name = "eks-with-disks"

#   key_name = "local-provisioner"

#   block_device_mappings {
#     device_name = "/dev/xvdb"

#     ebs {
#       volume_size = 50
#       volume_type = "gp2"
#     }
#   }
# }


resource "aws_eks_addon" "vpc-cni" {
  cluster_name      = aws_eks_cluster.main.name
  addon_name        = "vpc-cni"
  resolve_conflicts = "OVERWRITE"
  depends_on        = [
    aws_eks_node_group.private-nodes
  ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name      = aws_eks_cluster.main.name
  addon_name        = "coredns"
  addon_version     = "v1.8.7-eksbuild.3"
  #e.g., previous version v1.8.7-eksbuild.2 and the new version is v1.8.7-eksbuild.3
  resolve_conflicts = "OVERWRITE"
  depends_on        = [
    aws_eks_node_group.private-nodes
  ]
}
