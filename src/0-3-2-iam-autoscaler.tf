# ----------------------------------------------------------------------------------------------------------------------
# Get a policy JSON for assuming role according to the autoscaler
# ----------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "autoscaler_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
  depends_on = [
    aws_iam_openid_connect_provider.eks
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# A policy for allowing some actions according to the role we are creating for the auto-scaler
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "autoscaler" {
  name = "${terraform.workspace}-eks-cluster-autoscaler"
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
    Version = "2012-10-17"
  })
}

# ----------------------------------------------------------------------------------------------------------------------
# Create IAM role used from the Autoscaler Service Account
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "autoscaler" {
  assume_role_policy = data.aws_iam_policy_document.autoscaler_assume_role_policy.json
  name               = "tbc.eks.autoscaler.${local.project.slug}"
}

# ----------------------------------------------------------------------------------------------------------------------
# Attach the role with the permissions to make sure will be granted to execute its needed actions
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "autoscaler" {
  role       = aws_iam_role.autoscaler.name
  policy_arn = aws_iam_policy.autoscaler.arn
}