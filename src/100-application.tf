data "aws_iam_policy_document" "assume-role_deployments" {
  for_each = toset(var.K8S_NAMESPACES)
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = [
        format(
          "system:serviceaccount:%s:%s-sa",
          each.value,
          var.K8S_APPLICATIONS[each.value]
        )
      ]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_policy" "access-to-secrets" {
  for_each = toset(var.K8S_NAMESPACES)
  name     = "${replace(title(each.value), "_", "")}@AccessToSecrets"
  policy   = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:DescribeParameters",
          "ssm:GetParameters",
          "kms:Decrypt"
        ],
        "Resource" : [
          aws_kms_key.main.arn,
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${each.value}.*",
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/tbc.*.${each.value}.*",
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${terraform.workspace}.*",
        ]
      },

    ]
  })
}
resource "aws_iam_policy" "access-to-s3" {
  for_each = toset(var.K8S_NAMESPACES)
  name     = "${replace(title(each.value), "_", "")}@AccessToS3"
  policy   = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "kms:Decrypt"
        ],
        "Resource" : [
          aws_kms_key.main.arn,
          aws_s3_bucket.main[each.value].arn,
          "${aws_s3_bucket.main[each.value].arn}/*"
        ]
      },

    ]
  })
  depends_on = [
    aws_s3_bucket.main
  ]
}

resource "aws_iam_role" "deployments" {
  for_each           = toset(var.K8S_NAMESPACES)
  name               = "${replace(title(each.value), "_", "")}@ApplicationDeployment"
  assume_role_policy = data.aws_iam_policy_document.assume-role_deployments[each.value].json
}

resource "aws_iam_role_policy_attachment" "access-to-secrets" {
  for_each   = toset(var.K8S_NAMESPACES)
  role       = aws_iam_role.deployments[each.value].name
  policy_arn = aws_iam_policy.access-to-secrets[each.value].arn
}

resource "aws_iam_role_policy_attachment" "access-to-s3" {
  for_each   = toset(var.K8S_NAMESPACES)
  role       = aws_iam_role.deployments[each.value].name
  policy_arn = aws_iam_policy.access-to-s3[each.value].arn
}


