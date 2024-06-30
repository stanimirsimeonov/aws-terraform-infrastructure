# ----------------------------------------------------------------------------------------------------------------------
# Create a policy for manage EC2 instances from the EKS nodes
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "eks-node" {
  name               = "${replace(title(local.project.slug), "_", "")}@ServiceRoleForEKSNode"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Purpose = "Main role of the EKS"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Needed Permissions for the EKS Node  Role
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "cluser-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node.name
}

# ----------------------------------------------------------------------------------------------------------------------
# Needed Permissions for the EKS Node  Role
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "cluser-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node.name
}

# ----------------------------------------------------------------------------------------------------------------------
# Needed Permissions for the EKS Node  Role
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "cluser-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       =  aws_iam_role.eks-node.name
}
