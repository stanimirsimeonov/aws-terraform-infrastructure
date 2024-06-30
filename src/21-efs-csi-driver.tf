# ----------------------------------------------------------------------------------------------------------------------
# Create an IAM policy that allows the CSI driver's service account to make calls to AWS APIs on your behalf.
# ----------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "efs_csi_driver" {
  statement {
    actions = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets",
      "ec2:DescribeAvailabilityZones"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "elasticfilesystem:CreateAccessPoint"
    ]
    resources = ["*"]
    effect    = "Allow"
    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
  statement {
    actions = [
      "elasticfilesystem:DeleteAccessPoint"
    ]
    resources = ["*"]
    effect    = "Allow"
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
  statement {
    actions = [
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientMount",
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "elasticfilesystem:AccessedViaMountTarget"
      values   = ["true"]
    }
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Create the policy.
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "efs_csi_driver" {
  path        = "/"
  name        = "${local.project.slug}-AmazonEKS_EFS_CSI_Driver_Policy"
  description = "Policy for the EFS CSI driver"
  policy      = data.aws_iam_policy_document.efs_csi_driver.json
}


resource "kubernetes_service_account" "efs-csi-controller-sa" {
  metadata {
    name        = "efs-csi-controller-sa"
    namespace   = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" : aws_iam_policy.efs_csi_driver.arn
    }
  }

}


# ----------------------------------------------------------------------------------------------------------------------
# Get a policy JSON for assuming role according to the
# ----------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "efs_csi_driver_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
    }

  }
  depends_on = [
    aws_iam_openid_connect_provider.eks
  ]
}


resource "aws_iam_role" "efs_csi_driver" {
  name               = "${local.project.slug}-EFS-CSI-Driver"
  assume_role_policy = data.aws_iam_policy_document.efs_csi_driver_assume.json
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
  role       = aws_iam_role.efs_csi_driver.name
  policy_arn = aws_iam_policy.efs_csi_driver.arn
}


resource "helm_release" "kubernetes_efs_csi_driver" {
  depends_on = [kubernetes_service_account.efs-csi-controller-sa, aws_eks_node_group.private-nodes]
  name       = "aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
#  version    = "2.3.4"



  set {
    name  = "controller.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "efs-csi-controller-sa"
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.efs_csi_driver.arn
  }

  set {
    name = "node.serviceAccount.create"
    # We're using the same service account for both the nodes and controllers,
    # and we're already creating the service account in the controller config
    # above.
    value = "false"
  }

  set {
    name  = "node.serviceAccount.name"
    value = "efs-csi-controller-sa"
  }

  set {
    name  = "node.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.efs_csi_driver.arn
  }

}

# ----------------------------------------------------------------------------------------------------------------------
# Creating   EFS filesystem where we are going to store all our files
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_efs_file_system" "efs_csi_driver" {
  creation_token = "${title(local.project.slug)}-storage"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = "true"

}

output "aws_efs_file_system-efs_csi_driver-id" {
  value = aws_efs_file_system.efs_csi_driver.id
}

# ----------------------------------------------------------------------------------------------------------------------
# Setup a SG group for the EFS connection
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "efs_csi_driver" {
  vpc_id = aws_vpc.main.id
  name   = "${title(local.project.slug)}@EFS-2-EKS"
  description = "The security group is managing the traffic for the file sharing across the cluster"
  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
  tags = {
    Name : "tbc.ec2.sg.efs.${local.project.slug}"
  }
}

output "aws_security_group_efs_csi_driver_id" {
  value = aws_security_group.efs_csi_driver.id
}

resource "aws_security_group_rule" "allow_all_incoming_efs" {
  description= " Allow inbound efs traffic from ec2"
  from_port         = 2049
  to_port           = 2049
  protocol          = "TCP"
  security_group_id = aws_security_group.efs_csi_driver.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

output "aws_security_group_rule_allow_all_incoming_efs_id" {
  value = aws_security_group_rule.allow_all_incoming_efs.id
}


resource "aws_security_group_rule" "allow_all_outgoing_efs" {
  description= " Allow outbound efs traffic from ec2"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.efs_csi_driver.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

output "aws_security_group_rule_allow_all_outgoing_efs_id" {
  value = aws_security_group_rule.allow_all_outgoing_efs.id
}


resource "aws_efs_mount_target" "efs_csi_driver" {
  count = length(data.aws_availability_zones.available.names)
  file_system_id  = aws_efs_file_system.efs_csi_driver.id
  subnet_id = aws_subnet.privates[count.index].id
  security_groups = [aws_security_group.efs_csi_driver.id]
}
resource "aws_efs_access_point" "portal" {
  file_system_id = aws_efs_file_system.efs_csi_driver.id
  tags = {
    Name: "${local.project.slug}-Portal"
  }
  posix_user {
    gid = 82
    uid = 82
    secondary_gids = [82,1000, 101, 1001]
  }
  root_directory {
    creation_info {
      owner_gid   = 82
      owner_uid   = 82
      permissions = "0755"
    }
    path = "/opt/application/storage"
  }
}
output "aws_efs_access_point-Portal-Id" {
  value = aws_efs_access_point.portal.id
}

resource "kubernetes_storage_class_v1" "efs_csi_driver" {
  metadata {
    name = "efs-sc"
  }

  storage_provisioner = "efs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
#  parameters = {
#    provisioningMode = "efs-ap" # Dynamic provisioning
#    fileSystemId     = aws_efs_file_system.efs_csi_driver.id
#    directoryPerms   = "700"
#    gidRangeStart: "1000"
#    gidRangeEnd: "2000"
#
#  }
#
#  mount_options = [
##    "iam",
#    "tls"
#  ]

  depends_on = [
    aws_efs_file_system.efs_csi_driver,
    aws_efs_mount_target.efs_csi_driver
  ]
}


/*
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
*/
#resource "kubernetes_storage_class_v1" "gp3" {
#  metadata {
#    name = "gp3"
#  }
#
#  storage_provisioner    = "ebs.csi.aws.com"
#  allow_volume_expansion = true
#  reclaim_policy         = "Delete"
#  volume_binding_mode    = "WaitForFirstConsumer"
#  parameters = {
#    encrypted = true
#    fsType    = "ext4"
#    type      = "gp3"
#  }
#
#  depends_on = [
#    helm_release.kubernetes_efs_csi_driver
#  ]
#}


#resource "kubectl_manifest" "storage_class" {
#  count      = (var.enabled && var.create_storage_class) ? 1 : 0
#  yaml_body  = <<YAML
#kind: StorageClass
#apiVersion: storage.k8s.io/v1
#metadata:
#  name: ${var.storage_class_name}
#provisioner: efs.csi.aws.com
#YAML
#  depends_on = [helm_release.kubernetes_efs_csi_driver]
#}