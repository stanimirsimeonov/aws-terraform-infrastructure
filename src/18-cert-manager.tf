# ----------------------------------------------------------------------------------------------------------------------
# Get a policy JSON for assuming role according to the autoscaler
# ----------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "cert-manager_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:cert-manager:cert-manager"]
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

resource "aws_iam_policy" "cert-manager" {
  name   = "${title(terraform.workspace)}CertManagerDNSAccess"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      "Statement" : [

        {
          "Effect": "Allow",
          "Action": "route53:GetChange",
          "Resource": "arn:aws:route53:::change/*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "route53:ChangeResourceRecordSets",
            "route53:ListResourceRecordSets"
          ],
          "Resource" : [
            data.aws_route53_zone.main.arn
          ]
        },
        {
          "Effect": "Allow",
          "Action": "route53:ListHostedZonesByName",
          "Resource": "*"
        }

      ]
    }
  )
}

# ----------------------------------------------------------------------------------------------------------------------
# Create IAM role used from the CertManager  Service Account
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "cert-manager" {
  assume_role_policy = data.aws_iam_policy_document.cert-manager_assume_role_policy.json
  name               = "tbc.eks.cert-manager.${local.project.slug}"
}

# ----------------------------------------------------------------------------------------------------------------------
# Attach the role with the permissions to make sure will be granted to execute its needed actions
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "cert-manager" {
  role       = aws_iam_role.cert-manager.name
  policy_arn = aws_iam_policy.cert-manager.arn
}


resource "helm_release" "cert-manager" {
  name = "cert-manager"

  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  version          = "1.10.0"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cert-manager.arn
  }

  set {
    name  = "extraArgs[0]"
    value = "--issuer-ambient-credentials"
  }

  depends_on = [
    aws_eks_node_group.private-nodes,
  ]
}