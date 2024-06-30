#Main repository where the project is stored
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ecr_repository" "aws-ecr" {

  for_each = toset(var.ECR_REPOSITORIES)
  name = each.value
  image_tag_mutability = "MUTABLE"
  tags = {

  }

  #  encryption_configuration {
  #    kms_key = var.kms_key
  #  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ecr_lifecycle_policy" "main" {
  for_each = toset(var.ECR_REPOSITORIES)

  repository = aws_ecr_repository.aws-ecr[each.value].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "keep last 10 images"
      action       = {
        type = "expire"
      }
      selection     = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
    }]
  })
}


