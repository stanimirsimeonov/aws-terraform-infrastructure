#data "aws_iam_policy_document" "assume_role_iamserviceaccount_secrets_storage_csi" {
#
#  statement {
#    actions = ["sts:AssumeRoleWithWebIdentity"]
#    effect  = "Allow"
#
#    condition {
#      test     = "StringEquals"
#      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
#      values = [
#        format(
#          "system:serviceaccount:%s:%s",
#          "development",
#          "csi-secrets-store-provider-aws"
#        )
#      ]
#    }
#
#    principals {
#      identifiers = [aws_iam_openid_connect_provider.eks.arn]
#      type        = "Federated"
#    }
#  }
#}
#resource "aws_iam_role" "aws-provider-installer" {
#  name               = "${replace(title(local.project.slug), "_", "")}@SecretsStorageCSI_IAM_ServiceAccount"
#  assume_role_policy = data.aws_iam_policy_document.assume_role_iamserviceaccount_secrets_storage_csi.json
#}