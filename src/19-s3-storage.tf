resource "aws_s3_bucket" "logs" {
  bucket = "${terraform.workspace}-tbchealthcare-logs"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "logs" {
  bucket = aws_s3_bucket.logs.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "main" {
  for_each   = toset(var.K8S_NAMESPACES)
  bucket     = "${terraform.workspace}-${var.K8S_APPLICATION-BUCKETS[each.value]}"
  depends_on = [
    aws_s3_bucket.logs
  ]
}


resource "aws_s3_bucket_acl" "main" {
  for_each = toset(var.K8S_NAMESPACES)
  bucket   = aws_s3_bucket.main[each.value].id
  acl      = "private"
}


resource "aws_s3_bucket_logging" "main" {
  for_each      = toset(var.K8S_NAMESPACES)
  bucket        = var.K8S_APPLICATION-BUCKETS[each.value]
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "${var.K8S_APPLICATION-BUCKETS[each.value]}/"
}

