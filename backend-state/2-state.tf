resource "aws_kms_key" "state-bucket-key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "key-alias" {
  name          = "alias/state-bucket-key"
  target_key_id = aws_kms_key.state-bucket-key.id
  depends_on    = [aws_kms_key.state-bucket-key]
}
# ----------------------------------------------------------------------------------------------------------------------
# Provides a S3 bucket resource.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "terraform-state" {
  bucket     = "tbc-application-state"
  force_destroy = true
  depends_on = [
    aws_kms_key.state-bucket-key,
    aws_kms_alias.key-alias
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Provides an S3 bucket ACL resource.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket_acl" "terraform-state-bucket-acl" {
  bucket     = aws_s3_bucket.terraform-state.id
  acl        = "private"
  depends_on = [aws_s3_bucket.terraform-state]
}

# ----------------------------------------------------------------------------------------------------------------------
# Provides a resource for controlling versioning on an S3 bucket.
# Deleting this resource will either suspend versioning on the associated S3 bucket or simply remove the resource from
# Terraform state if the associated S3 bucket is unversioned.
# For more information, see https://docs.aws.amazon.com/AmazonS3/latest/userguide/manage-versioning-examples.html
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_versioning" "terraform-state-bucket-versioning" {
  bucket = aws_s3_bucket.terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }
  depends_on = [aws_s3_bucket.terraform-state]

}
# ----------------------------------------------------------------------------------------------------------------------
# Provides a S3 bucket server-side encryption configuration resource.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform-state-bucket-encryption-configuration" {
  bucket = aws_s3_bucket.terraform-state.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.state-bucket-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
  depends_on = [
    aws_s3_bucket.terraform-state,
    aws_kms_key.state-bucket-key,
    aws_kms_alias.key-alias
  ]

}


# ----------------------------------------------------------------------------------------------------------------------
# Manages S3 bucket-level Public Access Block configuration. For more information about these settings,
# see the AWS S3 Block Public Access documentation. https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "terraform-state-bucket-block" {
  bucket = aws_s3_bucket.terraform-state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform-state" {
  name           = "terraform-state"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  depends_on = [aws_s3_bucket.terraform-state]

}