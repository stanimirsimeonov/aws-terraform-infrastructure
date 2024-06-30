# ----------------------------------------------------------------------------------------------------------------------
# SSM role we are assigning to the role to be able cluster to read SSM parameters
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "ssm" {
  name   = "${replace(title(local.project.slug), "_", "")}@EKSClusterAllowSSMPolicy"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:DescribeParameters"
        ],
        "Resource" : "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters"
        ],
        "Resource" : "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/*"
      }

    ]
  })
}

# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "ecr" {
  name   = "${replace(title(local.project.slug), "_", "")}@EKSClusterAllowECRPolicy"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [

      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        "Resource" : "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        "Resource" : "*"
      }
    ]
  })
}


# ----------------------------------------------------------------------------------------------------------------------
# Role which is assigned to the cluster
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "eks" {
  name               = "${replace(title(local.project.slug), "_", "")}@ServiceRoleForEKS"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Purpose = "Main role of the EKS"
  }
}



# ----------------------------------------------------------------------------------------------------------------------
# Assign the main EKS polocy to the main role
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "cluster-main" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

# ----------------------------------------------------------------------------------------------------------------------
# Assign the main SSM policy to the main role
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "cluster-ssm" {
  policy_arn = aws_iam_policy.ssm.arn
  role       =  aws_iam_role.eks.name
}

# ----------------------------------------------------------------------------------------------------------------------
# Assign the main SSM policy to the main role
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "cluster-ecr" {
  policy_arn = aws_iam_policy.ecr.arn
  role       =  aws_iam_role.eks.name
}