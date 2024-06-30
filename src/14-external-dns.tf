# ----------------------------------------------------------------------------------------------------------------------
# Get a policy JSON for assuming role according to the autoscaler
# ----------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "external-dns_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:external-dns"]
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

resource "aws_iam_policy" "external-dns" {
  name   = "${title(terraform.workspace)}ExternalDNSAccess"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ChangeResourceRecordSets"
          ],
          "Resource" : [
            #            "arn:aws:route53:::hostedzone/*"
            data.aws_route53_zone.main.arn
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets"
          ],
          "Resource" : [
            "*"
          ]
        }
      ]
    }
  )
}

# ----------------------------------------------------------------------------------------------------------------------
# Create IAM role used from the External DNS Service Account
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "external-dns" {
  assume_role_policy = data.aws_iam_policy_document.external-dns_assume_role_policy.json
  name               = "tbc.eks.external-dns.${local.project.slug}"
}

# ----------------------------------------------------------------------------------------------------------------------
# Attach the role with the permissions to make sure will be granted to execute its needed actions
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "external-dns" {
  role       = aws_iam_role.external-dns.name
  policy_arn = aws_iam_policy.external-dns.arn
}

resource "kubernetes_service_account_v1" "external-dns" {
  metadata {
    name = "external-dns"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn": aws_iam_role.external-dns.arn
    }
  }
}

resource "kubectl_manifest" "external-dns_cluster-role" {
  yaml_body = file("./external-dns/1-cluster-role.yaml")
}

resource "kubectl_manifest" "external-dns_cluster-role-binding" {
  yaml_body = file("./external-dns/2-cluster-role-binding.yaml")
}

resource "kubectl_manifest" "external-dns_deployment" {
  yaml_body = file("./external-dns/3-deployment.yaml")
}
